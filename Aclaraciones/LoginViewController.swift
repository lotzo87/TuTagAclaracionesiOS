//
//  LoginViewController.swift
//  Aclaraciones
//
//  Created by ID Mexico on 05/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    var credenciales:NSDictionary?
    var credencialesInfo:NSArray?
    var conexion:NSURLConnection?
    var datosRecibidos:NSMutableData?
    var usuario:String?
    var contra:String?
    @IBOutlet weak var txtUsuario: UITextField!
    @IBOutlet weak var txtContra: UITextField!
    @IBAction func btnLogin(sender: AnyObject) {
       usuario =   self.txtUsuario.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
       contra =    self.txtContra.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if(usuario != "" && contra != ""){
                consultarCredenciales(usuario!, withContrasenia: contra!)
        }
        else{
           showAlert("Todos los campos son requeridos", titulo: "ERROR")
        }
    }
    
    @IBAction func btnRegistro(sender: AnyObject) {
        performSegueWithIdentifier("RegistroSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        credenciales = NSDictionary()
        // Do any additional setup after loading the view.
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(mensaje: NSString, titulo: NSString)
    {
        let ac:UIAlertController = UIAlertController(title: titulo as String, message: mensaje as String, preferredStyle: .Alert )
        let aac  = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        ac.addAction(aac)
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func consultarCredenciales(delUsuario: NSString, withContrasenia contra: NSString)
    {
        let urlString = "http://200.57.36.4/WebTuTag/TuTagBackEnd.asmx/DoLogin?usuario=\(delUsuario)&&contrasena=\(contra)"
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
    
    func validarAcceso()
    {
        if (credenciales != nil){
            let acceso = (credenciales!)
            if ((acceso["Login"] as! NSNumber) == 1){
                self.recuperarCredenciales();
                performSegueWithIdentifier("AccesoSegue", sender: self)
            }
            else{
                showAlert("Credeciales de acceso incorrectas. Intente nuevamente.", titulo: "ERROR")
            }
        }
        else{
            showAlert("No se obtuvo respuesta, intente nuevamente", titulo: "ERROR")
        }
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
            self.credenciales = arregloRecibido as! NSDictionary
            self.validarAcceso()
        }
        catch {
            print ("Error al recibir WS WebTuTag")
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.txtUsuario.resignFirstResponder()
        self.txtContra.resignFirstResponder()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AccesoSegue"){
            let navCtrl = segue.destinationViewController as! UINavigationController
            let destino = navCtrl.topViewController as! ViewController
            destino.credenciales = credencialesInfo
            destino.correo = usuario
        }

    }
    
    func recuperarCredenciales() {
        self.credencialesInfo = DBManager.instance.consultaCredenciales("CredencialesEntity", filtradosPor:NSPredicate(format: "correo=%@ AND contrasena=%@", usuario!, contra!))
    }
    

}
