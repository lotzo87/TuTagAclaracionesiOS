//
//  ViewController.swift
//  Aclaraciones
//
//  Created by ID Mexico on 04/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//

import UIKit

class MovimientoTableViewCell: UITableViewCell{

    @IBOutlet weak var lblCst: UILabel!
    @IBOutlet weak var lblImp: UILabel!
    @IBOutlet weak var lblCrr: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var credenciales:NSArray?
    var correo:String?
    var tarjeta2:NSArray?
    var tarjeta: String?
    var movimientos:NSArray?
    var conexion:NSURLConnection?
    var datosRecibidos:NSMutableData?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func btnRefresh(sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.movimientos=NSArray()
        //consultaMovimientos()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.delegate=self
        self.tableView.dataSource=self
        self.consultaTarjetas()
        self.consultaMovimientos()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // #warning Incomplete implementation, return the number of rows
        return self.movimientos!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("movCell", forIndexPath: indexPath) as! MovimientoTableViewCell
        let movimiento = (movimientos![indexPath.row]) as! NSDictionary
        let fecha = ((movimiento["Fecha"] as! NSString) as String) + " " + ((movimiento["Hora"] as! NSString) as String)
        cell.lblCst?.text = (movimiento["Caseta"] as! NSString) as String
        cell.lblImp?.text = (movimiento["Monto"] as! NSNumber).stringValue
        cell.lblFecha.text = fecha
        cell.lblCrr?.text = (movimiento["Tramo"] as! NSString) as String
        return cell
    }
    
    func consultaMovimientos() {
        //let urlString = "http://151.1.8.113/WebTuTag/TuTagBackEnd.asmx/GetMovientosTagJsom?tagId=\(tarjeta)&fechaInicio=01/01/2015&fechaFin=01/12/2016"
        //IMDM21811688
        var tag:String=""
        if tarjeta2 != nil
        {
            tag = (tarjeta2?.valueForKey("tarjeta"))! as! String
        }
        let urlString = "http://200.57.36.4/WebTuTag/TuTagBackEnd.asmx/GetMovientosTagJsom?tagId=\(tag)&&fechaInicio=01/01/2015&&fechaFin=01/12/2016"
        let laURL = NSURL(string: urlString)!
        let elRequest = NSURLRequest(URL: laURL)
        self.datosRecibidos = NSMutableData(capacity: 0)
        self.conexion = NSURLConnection(request: elRequest, delegate: self, startImmediately: true)
        if self.conexion == nil {
            self.datosRecibidos = nil
            self.conexion = nil
            print ("No se puede acceder al WS WebTuTag")
        }
       
    }
    
    func consultaTarjetas()
    {
        self.tarjeta2 = DBManager.instance.consultaTarjetas("TarjetasEntity", filtradosPor:NSPredicate(format: "ANY credenciales.correo LIKE %@", correo!))
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
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
            let arregloRecibido = try NSJSONSerialization.JSONObjectWithData(self.datosRecibidos!, options: .AllowFragments) as! NSArray
            self.movimientos = arregloRecibido
            self.tableView.reloadData()
        }
        catch {
            print ("Error al recibir webservice de Estados")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AclaracionSegue"
        {
            let navCtrl = segue.destinationViewController as! UINavigationController
            let destino = navCtrl.topViewController as! AclaracionViewController
            let seleccion = tableView.indexPathForSelectedRow
            destino.movimiento = movimientos![seleccion!.row] as! NSDictionary
        }
        
    }
}

