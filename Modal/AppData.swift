import UIKit
import CoreData
@available(iOS 13.0, *)
class AppData {
    var transactions = [Transactions]()
    var categories = [Categories]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedExpense = 0
    var selectedIncome = 0
    func stringDate(_ sender: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: sender.date)
    }
    var sumIncomes: Double = 0.0
    var sumExpenses: Double = 0.0
    var sumPeriodBalance: Double = 0.0
    func recalculation(b: UILabel, i:UILabel, e: UILabel, data: [Transactions]) {
        sumIncomes = 0.0
        sumExpenses = 0.0
        sumPeriodBalance = 0.0
        var arreyNegative: [Double] = [0.0]
        var arreyPositive: [Double] = [0.0]
        for i in 0..<data.count {
            sumPeriodBalance = sumPeriodBalance + data[i].value
            if data[i].value > 0 {
                arreyPositive.append(data[i].value)
                sumIncomes = sumIncomes + data[i].value
            } else {
                arreyNegative.append(data[i].value)
                sumExpenses = sumExpenses + data[i].value
            }}
        if sumPeriodBalance < Double(Int.max), sumIncomes < Double(Int.max), sumExpenses < Double(Int.max) {
            i.text = "\(Int(sumIncomes))"
            e.text = "\(Int(sumExpenses) * -1)"
        } else {
            i.text = "\(sumIncomes)"
            e.text = "\(sumExpenses * -1)"
        }
    }
    var objects = Objects()
    struct Objects {
        var amountField = UITextField()
        var expensesField = UITextField()
        var expensesPicker = UIPickerView()
        let datePicker = UIDatePicker()
        var incomePicker = UIPickerView()
    }
    var filter = Filter()
    struct Filter {
        var showAll = true
        var from: String = ""
        var to: String = ""
        var lastNumber = 31
        func getFirstDay(_ sender: UIDatePicker) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "01.MM.yyyy"
            return dateFormatter.string(from: sender.date)
        }
        func getLastDay(_ sender: UIDatePicker) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "\(lastNumber).MM.yyyy"
            return dateFormatter.string(from: sender.date)
        }
        var filterObjects = FilterObjects()
        struct FilterObjects {
            let currentDate = UIDatePicker()
            var startDatePicker = UIDatePicker()
            var endDatePicker = UIDatePicker()
            var startDateField = UITextField()
            var endDateField = UITextField()
        }
    }
    var categoryVC = CategoryVCBrain()
    struct CategoryVCBrain {
        let allPurposes = [K.expense, K.income]
        var categoryTextField = UITextField()
        var purposPicker = UIPickerView()
        var purposeField = UITextField()
        var selectedPurpose = 0
    }
}
extension Transactions {
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,]
        return formatter
    }()
    var dateFromString: Date {
        let dateString = date!.components(separatedBy: ".").reversed().joined(separator: ".")
        return Transactions.isoFormatter.date(from: dateString)!
    }
}
