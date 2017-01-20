//
//  Aclaraciones+CoreDataProperties.swift
//  Aclaraciones
//
//  Created by ID Mexico on 19/01/17.
//  Copyright © 2017 ID Mexico. All rights reserved.
//

import Foundation
import CoreData


extension Aclaraciones {

   

    @NSManaged public var caseta: String?
    @NSManaged public var importe: Double
    @NSManaged public var h_cruce: String?
    @NSManaged public var f_cruce: String?
    @NSManaged public var dictamen: String?
    @NSManaged public var devolucion: Double
    @NSManaged public var estatus: Int16
    @NSManaged public var f_dictamen: String?
    @NSManaged public var f_alta: String?
    @NSManaged public var id_folio: String?

}
