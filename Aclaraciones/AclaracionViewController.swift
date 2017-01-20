//
//  AclaracionViewController.swift
//  Aclaraciones
//
//  Created by ID Mexico on 12/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//

import UIKit

class AclaracionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var conexion:NSURLConnection?
    var datosRecibidos:NSMutableData?
    var movimiento:NSDictionary?
    var idmotivo:Int?
    var folio:NSDictionary?
    //var motivos = ["Diferencia de tarifa","Cruce duplicado","Cargo no reconocido","Cruce no reconocido","Pago en efectivo"]
    let motivos:[(id: Int, motivo: String)] = [(1,"Diferencia de tarifa"),(2,"Cruce duplicado"),(3,"Cargo no reconocido"),(4,"Cruce no reconocido"),(5,"Pago en efectivo")]
    @IBOutlet weak var lblTarjeta: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var lblHora: UILabel!
    @IBOutlet weak var lblCaseta: UILabel!
    @IBOutlet weak var lblCosto: UILabel!
    @IBOutlet weak var lblCorredor: UILabel!
    @IBOutlet weak var pckrMotivos: UIPickerView!
    @IBOutlet weak var imgComp: UIImageView!
    
    @IBOutlet weak var toolBarComp: UIToolbar!
    @IBOutlet weak var btnComp: UIBarButtonItem!
    @IBAction func btnCamara(sender: AnyObject) {
            self.abrirCamara()
    }
    
    @IBAction func btnContinuar(sender: AnyObject) {
        if (idmotivo == 5 && imgComp.image == nil)
        {
            showAlert("Se requiere comprobante de pago. Intente nuevamente", titulo: "ERROR")
        }
        else{
            generarAclaracion()
        }
    }
    @IBAction func btnCancelar(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTarjeta.text = "IMDM20651328.."
        self.lblFecha.text = (self.movimiento?.valueForKey("Fecha")as! String)
        self.lblHora.text = (self.movimiento?.valueForKey("Hora")as! String)
        self.lblCaseta.text = (self.movimiento?.valueForKey("Caseta")as! String)
        let monto = (self.movimiento?.valueForKey("Monto") as! NSNumber).stringValue
        self.lblCosto.text = monto
        self.lblCorredor.text = (self.movimiento?.valueForKey("Tramo")as! String)
        // Do any additional setup after loading the view.
        btnComp.enabled = false
        idmotivo = motivos[0].id
        folio = NSDictionary()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generarAclaracion()
    {
        let urlString = "http://200.57.36.4/WebTuTag/TuTagBackEnd.asmx/GeneraAclaracionUP?clatran=0&&numtar=IMDM20651328..&&tipousr=0&&importe=\((self.movimiento?.valueForKey("Monto") as! NSNumber).stringValue)&&idmotivo=\((idmotivo! as NSNumber).stringValue)&&fecha=\((self.movimiento?.valueForKey("Fecha")as! String))&&hora=\((self.movimiento?.valueForKey("Hora")as! String))&&ncarril=\((self.movimiento?.valueForKey("Carril")as! String))&&comentario=\("")"
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
    
    func showAlert(mensaje: NSString, titulo: NSString)
    {
        let ac:UIAlertController = UIAlertController(title: titulo as String, message: mensaje as String, preferredStyle: .Alert )
        let aac  = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        ac.addAction(aac)
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func abrirCamara()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            let imgPicker = UIImagePickerController()
            imgPicker.sourceType = UIImagePickerControllerSourceType.Camera
            imgPicker.modalPresentationStyle = .FullScreen
            imgPicker.allowsEditing = false
            imgPicker.delegate = self
            self.presentViewController(imgPicker, animated: true, completion: nil)
        }

    }
    
    
    func validarRespuesta()
    {
        if (folio != nil){
            self.showAlert("Aclaración ingresada con folio \((folio?.valueForKey("comentario") as! NSString))", titulo: "AVISO")
        }
        else{
            self.showAlert("No se obtuvo respuesta, intente nuevamente", titulo: "ERROR")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return motivos.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return motivos[row].motivo
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        idmotivo = motivos[row].id
        if (idmotivo == 5)
        {
            btnComp.enabled = true
            self.abrirCamara()
        }
        else
        {
            imgComp.image = nil
            btnComp.enabled = false
        }
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let imagen = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imgComp.contentMode = .ScaleAspectFit
            imgComp.image = imagen
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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
            self.folio = (arregloRecibido as! NSDictionary)
            validarRespuesta()
        }
        catch {
            print ("Error al recibir WS WebTuTag")
        }
    }
    
}
