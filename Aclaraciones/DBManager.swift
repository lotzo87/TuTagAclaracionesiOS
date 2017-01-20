//
//  DBManager.swift
//  Aclaraciones
//
//  Created by ID Mexico on 19/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//

import Foundation
import CoreData

class DBManager {
    
    // Declaración del singleton
    static let instance = DBManager()
    
    func consultaCredenciales(nombreEntidad:String, filtradosPor:NSPredicate )-> NSArray {
        let elQuery:NSFetchRequest = NSFetchRequest()
        let laEntidad:NSEntityDescription = NSEntityDescription.entityForName(nombreEntidad, inManagedObjectContext: self.managedObjectContext!)!
        elQuery.entity = laEntidad
        elQuery.predicate = filtradosPor
        do { // try-catch al estilo swift...
            let result = try self.managedObjectContext!.executeFetchRequest(elQuery)
            return result as NSArray
        }
        catch {
            print ("Error al ejecutar request")
            return NSArray()
        }
    }
    
    func consultaTarjetas(nombreEntidad:String, filtradosPor:NSPredicate )-> NSArray{
        let elQuery:NSFetchRequest = NSFetchRequest()
        let laEntidad:NSEntityDescription = NSEntityDescription.entityForName(nombreEntidad, inManagedObjectContext: self.managedObjectContext!)!
        elQuery.entity = laEntidad
        elQuery.predicate = filtradosPor
        do { // try-catch al estilo swift...
            let result = try self.managedObjectContext!.executeFetchRequest(elQuery)
            return result as NSArray
        }
        catch {
            print ("Error al ejecutar request: \(error)")
            return NSArray()
        }
    }
   
    func guardarCredenciales(nombreEntidad:String, nombreEntidad2:String, contra:String, correo:String, numero:String, alias:String, tarjeta:String, tipo:NSNumber )
    {
        let laCredencial = NSEntityDescription.insertNewObjectForEntityForName(nombreEntidad, inManagedObjectContext: self.managedObjectContext!) as! Credenciales
        let laTarjeta = NSEntityDescription.insertNewObjectForEntityForName(nombreEntidad2, inManagedObjectContext: self.managedObjectContext!) as! Tarjetas
        laCredencial.setValue(contra, forKey: "contrasena")
        laCredencial.setValue(correo, forKey: "correo")
        laCredencial.setValue(numero, forKey: "n_celular")
        laCredencial.setValue(1, forKey: "estatus")
        laTarjeta.setValue(alias, forKey: "alias")
        laTarjeta.setValue(tarjeta, forKey: "tarjeta")
        laTarjeta.setValue(tipo, forKey: "tipo")
        laCredencial.addToTarjetas(laTarjeta)
        do {
            try managedObjectContext?.save()
        } catch {
            fatalError("Error al guardar: \(error)")
        }
    }
    
    lazy var managedObjectContext:NSManagedObjectContext? = {
        let persistence = self.persistentStore
        if persistence == nil {
            return nil
        }
        var moc = NSManagedObjectContext(concurrencyType:.PrivateQueueConcurrencyType)
        moc.persistentStoreCoordinator = persistence
        return moc
    }()
    lazy var managedObjectModel:NSManagedObjectModel? = {
        let modelURL = NSBundle.mainBundle().URLForResource("Tu_Tag_Core_Data", withExtension: "momd")
        var model = NSManagedObjectModel(contentsOfURL: modelURL!)
        return model
    }()
    lazy var persistentStore:NSPersistentStoreCoordinator? = {
        let model = self.managedObjectModel
        if model == nil {
            return nil
        }
        let persist = NSPersistentStoreCoordinator(managedObjectModel: model!)
        // Encontrar la ubicacion de la base de datos...
        let urlDeLaBD = self.directorioDocuments.URLByAppendingPathComponent("Tu_Tag_Core_Data.sqlite")
        do {
            let opcionesDePersistencia = [NSMigratePersistentStoresAutomaticallyOption:true,
                                          NSInferMappingModelAutomaticallyOption:true]
            try persist.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:urlDeLaBD, options:opcionesDePersistencia)
        }
        catch {
            print ("no se puede abrir la base de datos")
            abort()
        }
        return persist
    }()
    lazy var directorioDocuments:NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1] 
    }()
}

