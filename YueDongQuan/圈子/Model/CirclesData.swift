//
//	CirclesData.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class CirclesData : NSObject, NSCoding{

	var array : [CirclesArray]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		array = [CirclesArray]()
		if let arrayArray = dictionary["array"] as? [NSDictionary]{
			for dic in arrayArray{
				let value = CirclesArray(fromDictionary: dic)
				array.append(value)
			}
		}
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if array != nil{
			var dictionaryElements = [NSDictionary]()
			for arrayElement in array {
				dictionaryElements.append(arrayElement.toDictionary())
			}
			dictionary["array"] = dictionaryElements
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         array = aDecoder.decodeObjectForKey("array") as? [CirclesArray]

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encodeWithCoder(aCoder: NSCoder)
	{
		if array != nil{
			aCoder.encodeObject(array, forKey: "array")
		}

	}

}
