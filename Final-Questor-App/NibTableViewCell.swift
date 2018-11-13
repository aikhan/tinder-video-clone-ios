import UIKit


final class NibTableViewCell: UITableViewCell, Cell, UITextFieldDelegate {

    // MARK: - Properties

    @IBOutlet weak var textField: UITextField!
    // MARK: - CellType

    static func nib() -> UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    func configure(row: Row) {
        textField.delegate = self
        textField.returnKeyType = .done
        
        let firstName = DAO.getCurrentLoggedUser()!.firstName!
        let location = DAO.getCurrentLoggedUser()!.userLocation!
        
        //Get property from user defalauts
        if row.text == "firstName"{
            //Set the user's first name to row
            textField.text = firstName
        }
        else{
            //Set the user's location to row
            textField.text = location
        }
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
}
