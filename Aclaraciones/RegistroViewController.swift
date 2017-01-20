//
//  RegistroViewController.swift
//  Aclaraciones
//
//  Created by ID Mexico on 10/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//

import UIKit
import CoreData

class RegistroViewController: UIViewController {
    var conexion:NSURLConnection?
    var datosRecibidos:NSMutableData?
    var registro:NSArray?
    var numero:String?
    var correo:String?
    var contra:String?
    var tarjeta3:(alias: String, prefijo: String, numero: String, tipo: NSNumber)?
    @IBAction func btnContinuar(sender: AnyObject) {
        numero =   self.txtNumero.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        correo =  self.txtCorreo.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        contra = self.txtContra.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let confContra = self.txtConfirma.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if(numero != "" && correo != "" && contra != "" && confContra != ""){
            if (validarCorreo(correo!))
            {
                if (contra == confContra)
                {
                   registrar(tarjeta3!.alias, conPrefijo: tarjeta3!.prefijo, conNumero: tarjeta3!.numero, conCelular: numero!, conCorreo: correo!, conContra: contra!, conTipo: tarjeta3!.tipo )
                }
                else{
                    showAlert("Las contraseñas no coinciden. Intente nuevamante")
                }
            }
            else{
                showAlert("Correo no válido. Intente nuevamante")
            }
        }
        else{
            showAlert("Todos los campos son requeridos")
        }
    }
    
    @IBAction func btnCancelar(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet weak var txtNumero: UITextField!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContra: UITextField!
    @IBOutlet weak var txtConfirma: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validarCorreo(cuenta: String) -> Bool
    {
        let regExp = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let correoTest = NSPredicate(format: "SELF MATCHES %@", regExp)
        return correoTest.evaluateWithObject(cuenta)
    }

    func showAlert(mensaje: NSString)
    {
        let ac:UIAlertController = UIAlertController(title: "ERROR", message: mensaje as String, preferredStyle: .Alert )
        let aac  = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        ac.addAction(aac)
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func registrar(alias: String,  conPrefijo prefijo: String, conNumero numero: String, conCelular celular: String, conCorreo correo: String, conContra contra: String, conTipo tipo: NSNumber)
    {
        let urlString = "http://200.57.36.4/WebTuTag/TuTagBackEnd.asmx/RegisterNew?idcliente=0&&Alias=\(alias)&&prefijo=\(prefijo)&&numtar=\(numero)&&celular=\(celular)&&email=\(correo)&&contrasena=\(contra)&&tipopago=\(tipo)"
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
    
    func guardarCredenciales() {
        // create an instance of our managedObjectContext
        DBManager.instance.guardarCredenciales("CredencialesEntity",nombreEntidad2: "TarjetasEntity",contra:contra!, correo:correo!, numero:numero!, alias:tarjeta3!.alias, tarjeta:tarjeta3!.prefijo + tarjeta3!.numero + "..", tipo:tarjeta3!.tipo)
    }
    
    
    func validarRegistro()
    {
        if (registro != nil) {
            self.guardarCredenciales()
            performSegueWithIdentifier("DetalleSegue", sender: self)
        }
        else{
            showAlert("No se pudo realizar el registro. Intente nuevamente")
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
            self.registro = (arregloRecibido as! NSArray)
            self.validarRegistro()
        }
        catch {
            print ("Error al recibir WS WebTuTag")
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.txtNumero.resignFirstResponder()
        self.txtCorreo.resignFirstResponder()
        self.txtContra.resignFirstResponder()
        self.txtConfirma.resignFirstResponder()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navCtrl = segue.destinationViewController as! UINavigationController
        let destino = navCtrl.topViewController as! ViewController
        destino.tarjeta = (tarjeta3?.prefijo)!  + (tarjeta3?.numero)!
        
    }
    

}
