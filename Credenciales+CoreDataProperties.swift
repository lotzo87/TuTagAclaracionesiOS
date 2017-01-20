//
//  Credenciales+CoreDataProperties.swift
//  Aclaraciones
//
//  Created by ID Mexico on 19/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Credenciales {

 

    @NSManaged public var n_celular: String?
    @NSManaged public var correo: String?
    @NSManaged public var contrasena: String?
    @NSManaged public var estatus: Int16
    @NSManaged public var tarjetas: NSSet?

}

// MARK: Generated accessors for tarjetas
extension Credenciales {

    @objc(addTarjetasObject:)
    @NSManaged public func addToTarjetas(_ value: Tarjetas)

    @objc(removeTarjetasObject:)
    @NSManaged public func removeFromTarjetas(_ value: Tarjetas)

    @objc(addTarjetas:)
    @NSManaged public func addToTarjetas(_ values: NSSet)

    @objc(removeTarjetas:)
    @NSManaged public func removeFromTarjetas(_ values: NSSet)

}
