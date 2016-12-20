//
//  SerieError.swift
//  Series
//
//  Created by Florian Pygmalion on 19/12/2016.
//
//

import Foundation

public enum SerieError: Error {

    case ConnectionRefused
    case IDNotFound(String)
    case CreationError(String)
    case ParseError
    case AuthError
    case Invalid(String)
    case Unknown
    
}
