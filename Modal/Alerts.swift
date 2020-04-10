import UIKit
@available(iOS 13.0, *)
class Alerts {
    func alertTextField(alert: UIAlertController) {
        alert.addTextField { (dateFrom) in
            appData.filter.filterObjects.startDatePicker.datePickerMode = .date
            dateFrom.inputView = appData.filter.filterObjects.startDatePicker
            dateFrom.placeholder = "From"
            appData.filter.filterObjects.startDateField = dateFrom
            appData.filter.filterObjects.startDatePicker.addTarget(self, action: #selector(self.startDatePickerChangedValue(sender:)), for: .valueChanged)
        }
        alert.addTextField { (dateTo) in
            appData.filter.filterObjects.endDatePicker.datePickerMode = .date
            dateTo.inputView = appData.filter.filterObjects.endDatePicker
            dateTo.placeholder = "To"
            appData.filter.filterObjects.endDateField = dateTo
            appData.filter.filterObjects.endDatePicker.addTarget(self, action: #selector(self.endDatePickerChangedValue(sender:)), for: .valueChanged)
        }
    }
    @objc func startDatePickerChangedValue(sender: UIDatePicker) {
        appData.filter.filterObjects.startDateField.text = appData.stringDate(sender)
    }
    @objc func endDatePickerChangedValue(sender: UIDatePicker) {
        appData.filter.filterObjects.endDateField.text = appData.stringDate(sender)
    }
}
