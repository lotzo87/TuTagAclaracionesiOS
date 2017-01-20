//
//  JsonManager.swift
//  Aclaraciones
//
//  Created by ID Mexico on 04/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//
import UIKit
import Foundation

public protocol JsonManagerDelegate: NSObjectProtocol{
    func ConsultaMovimientosResponce(responseArray:NSArray)
}

public class JsonManager:NSObject
{
    var delegate:JsonManagerDelegate?
    static let _instance = JsonManager()
    
    var movimientos:NSArray?
    var conexion:NSURLConnection?
    var datosRecibidos:NSMutableData?
    
    
    func consultarMovimientos() -> NSArray{
        let urlString = "http://151.1.8.113/WebTuTag/TuTagBackEnd.asmx/GetMovientosTagJsom?tagId=CPFI00272726&fechaInicio=01/01/2015&fechaFin=01/12/2016"
        let laURL = NSURL(string: urlString)!
        let elRequest = NSURLRequest(URL: laURL)
        self.datosRecibidos = NSMutableData(capacity: 0)
        self.conexion = NSURLConnection(request: elRequest, delegate: self)
        if self.conexion == nil {
            self.datosRecibidos = nil
            self.conexion = nil
            print ("No se puede acceder al WS WebTuTag")
        }
        return movimientos!
    }
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.datosRecibidos = nil
        self.conexion = nil
        print ("No se puede acceder al WS WebTuTag: Error del server")
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) { // Ya se logrò la conexion, preparando para recibir datos
        self.datosRecibidos?.length = 0
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) { // Se recibiò un paquete de datos. guardarlo con los demàs
        self.datosRecibidos?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection){
        do {
            let arregloRecibido = try  NSJSONSerialization.JSONObjectWithData(self.datosRecibidos!, options: .AllowFragments) as! NSArray
            self.movimientos = arregloRecibido
            if delegate != nil{
                if delegate!.respondsToSelector("ConsultaMovimientosResponce") {
                    delegate!.ConsultaMovimientosResponce(movimientos!)
                }
            }
        }
        catch {
            print ("Error al recibir webservice de Estados")
        }
    }
    
}
