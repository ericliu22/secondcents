use std::path::Path;

use pyo3::{
    prelude::*,
    types::{PyModule, PyFloat, PyInt, PyString},

};

pub fn python_float(filename: &str, function_name: &str) -> Result<f64, PyErr>{
    let path = Path::new(filename);
    let code: String = std::fs::read_to_string(path).unwrap();
    Python::with_gil(|py| -> Result<f64, PyErr> {
        let module: &PyModule = match PyModule::from_code(py, &code, "example.py", "example") {
            Ok(module) => module,
            Err(err) => {return Err(err);}
        };
        let function = match module.getattr(function_name) {
            Ok(function) => function,
            Err(err) => {return Err(err);}
        };
        let result: &PyAny = match function.call0() {
            Ok(result) => result,
            Err(err) => {return Err(err);}
        };
        PyFloat::try_from_exact(result).unwrap().extract()
    })
}

pub fn python_string(filename: &str, function_name: &str) -> Result<String, PyErr>{
    let path = Path::new(filename);
    let code: String = std::fs::read_to_string(path).unwrap();
    Python::with_gil(|py| -> Result<String, PyErr> {
        let module: &PyModule = match PyModule::from_code(py, &code, "example.py", "example") {
            Ok(module) => module,
            Err(err) => {return Err(err);}
        };
        let function = match module.getattr(function_name) {
            Ok(function) => function,
            Err(err) => {return Err(err);}
        };
        let result: &PyAny = match function.call0() {
            Ok(result) => result,
            Err(err) => {return Err(err);}
        };
        PyString::try_from_exact(result).unwrap().extract()
    })
}

pub fn python_int(filename: &str, function_name: &str) -> Result<usize, PyErr>{
    let path = Path::new(filename);
    let code: String = std::fs::read_to_string(path).unwrap();
    Python::with_gil(|py| -> Result<usize, PyErr> {
        let module: &PyModule = match PyModule::from_code(py, &code, "example.py", "example") {
            Ok(module) => module,
            Err(err) => {return Err(err);}
        };
        let function = match module.getattr(function_name) {
            Ok(function) => function,
            Err(err) => {return Err(err);}
        };
        let result: &PyAny = match function.call0() {
            Ok(result) => result,
            Err(err) => {return Err(err);}
        };
        PyInt::try_from_exact(result).unwrap().extract()
    })
}
