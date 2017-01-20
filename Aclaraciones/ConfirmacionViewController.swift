//
//  ConfirmacionViewController.swift
//  Aclaraciones
//
//  Created by ID Mexico on 10/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//

import UIKit

class ConfirmacionViewController: UIViewController {
    internal var tarjeta2:(alias: String, prefijo: String, numero: String, tipo: NSNumber) = ("","","",0)
    var alias: String  = ""
    var prefijo: String = ""
    var numero: String = ""
    var conexion:NSURLConnection?
    var datosRecibidos:NSMutableData?
    var tarjeta:NSArray?
    @IBOutlet weak var txtPrimeros: UITextField!
    @IBOutlet weak var txtUltimos: UITextField!
    @IBAction func btnContinuar(sender: AnyObject) {
        
        let losPrimeros =   self.txtPrimeros.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let losUltimos =  self.txtUltimos.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if(losPrimeros != "" && losUltimos != ""){
            consultarPropiedad(tarjeta2.prefijo + tarjeta2.numero, conPrimeros: losPrimeros!, yUltimos: losUltimos!)
        }
        else{
            showAlert("Todos los campos son requeridos")
        }
    }
    
    
    @IBAction func btnCancelar(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func consultarPropiedad(delTag: String, conPrimeros pDigitos: String, yUltimos uDigitos: String)
    {
        let urlString = "http://200.57.36.4/WebTuTag/TuTagBackEnd.asmx/ValidaPropiedadTag?numtar=\(delTag)&&primeros=\(pDigitos)&&ultimos=\(uDigitos)"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(mensaje: NSString)
    {
        let ac:UIAlertController = UIAlertController(title: "ERROR", message: mensaje as String, preferredStyle: .Alert )
        let aac  = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        ac.addAction(aac)
        self.presentViewController(ac, animated: true, completion: nil)
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
            self.tarjeta = (arregloRecibido as! NSArray)
            self.validarPropiedad()
        }
        catch {
            print ("Error al recibir WS WebTuTag")
        }
    }
    
    func validarPropiedad()
    {
        if (tarjeta != nil)
        {
            if (tarjeta![0].valueForKey("success") as! String) == "Correcto"
            {
                
                performSegueWithIdentifier("RegistraSegue", sender: self)
            }
            else
            {
                showAlert("La datos nos son correctos. Intente nuevamente")
            }
        }
        else
        {
            showAlert("No se obtuvo respuesta. Intente nuevamente")
        }
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navCtrl = segue.destinationViewController as! UINavigationController
        let destino = navCtrl.topViewController as! RegistroViewController
        destino.tarjeta3 = tarjeta2
    }
    

}
