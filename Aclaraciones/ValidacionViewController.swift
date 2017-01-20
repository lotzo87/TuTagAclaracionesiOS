//
//  RegistroViewController.swift
//  Aclaraciones
//
//  Created by ID Mexico on 09/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//

import UIKit

class ValidacionViewController: UIViewController {
    var tarjeta:(alias: String, prefijo: String, numero: String, tipo: NSNumber) = ("","","",0)
    var conexion:NSURLConnection?
    var datosRecibidos:NSMutableData?
    var tarjetaVal:NSArray?
    @IBOutlet weak var txtAlias: UITextField!
    @IBOutlet weak var txtNumtag: UITextField!
    @IBOutlet weak var segPrefijo: UISegmentedControl!
    @IBAction func btnRegContinuar(sender: AnyObject) {
        let alias =   self.txtAlias.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let prefijo =  self.segPrefijo.titleForSegmentAtIndex(segPrefijo.selectedSegmentIndex)
        let numtag =  self.txtNumtag.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if(alias != "" && numtag != ""){
            tarjeta.alias = alias!
            tarjeta.prefijo = prefijo!
            tarjeta.numero  = numtag!
            consultarTarjeta(prefijo! + numtag!)
        }
        else{
            showAlert("Todos los campos son requeridos")
        }
    }
    
    @IBAction func btnCancelar(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func consultarTarjeta(numero: NSString)
    {
        let urlString = "http://200.57.36.4/WebTuTag/TuTagBackEnd.asmx/ValidationTag?numtar=\(numero)"
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
    
    func registrarTarjeta()
    {
        
    }
    
    func validarRespuesta()
    {
        if (tarjetaVal != nil)
        {
            if (tarjetaVal![0].valueForKey("validacion") as! NSNumber) == 1
            {
                if (tarjetaVal![1].valueForKey("validacion") as! NSNumber) == 1
                {
                    showAlert("La tarjeta ya se encuentra registrada")
                }
                else
                {
                    tarjeta.tipo = tarjetaVal![0].valueForKey("tipoPago") as! NSNumber
                    if tarjeta.tipo == 2
                    {
                        performSegueWithIdentifier("RegistraPreSegue", sender: self)
                    }
                    else
                    {
                        performSegueWithIdentifier("ConfirmaSegue", sender: self)
                    }
                }
            }
            else
            {
                showAlert("La tarjeta no existe en el catálogo. Intente nuevamente")
            }
        }
        else
        {
            showAlert("No se obtuvo respuesta. Intente nuevamente")
        }
    }
    
    func showAlert(mensaje: NSString)
    {
        let ac:UIAlertController = UIAlertController(title: "ERROR", message: mensaje as String, preferredStyle: .Alert )
        let aac  = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        ac.addAction(aac)
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tarjetaVal = NSArray()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let arregloRecibido = try NSJSONSerialization.JSONObjectWithData(self.datosRecibidos!, options: .AllowFragments)
            self.tarjetaVal = (arregloRecibido as! NSArray)
            self.validarRespuesta()
        }
        catch {
            print ("Error al recibir WS WebTuTag")
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.txtAlias.resignFirstResponder()
        self.txtNumtag.resignFirstResponder()
        self.segPrefijo.resignFirstResponder()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "ConfirmaSegue"
        {
            let navCtrl = segue.destinationViewController as! UINavigationController
            let destino = navCtrl.topViewController as! ConfirmacionViewController
            destino.tarjeta2 = tarjeta
        }
        else if segue.identifier == "RegistraPreSegue"
        {
            let navCtrl = segue.destinationViewController as! UINavigationController
            let destino = navCtrl.topViewController as! RegistroViewController
            destino.tarjeta3 = tarjeta
            
            
        }
    }
    

}
