using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Windows;
using System.Windows.Input;
using Microsoft.EntityFrameworkCore;
using RestaurantManagement.Models;
using OfficeOpenXml; 
using System.IO;
using Microsoft.Win32;
using System.Diagnostics;

namespace RestaurantManagement.ViewModels
{
    internal class TableStateViewModel : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        private ObservableCollection<Table> _tables;
        public ObservableCollection<Table> Tables
        {
            get => _tables;
            set
            {
                _tables = value;
                OnPropertyChanged(nameof(Tables));
            }
        }

        private string _titleOfBill;
        public string TitleOfBill
        {
            get => _titleOfBill;
            set
            {
                _titleOfBill = value;
                OnPropertyChanged(nameof(TitleOfBill));
            }
        }

        private ObservableCollection<BillItem> _billItems;
        public ObservableCollection<BillItem> BillItems
        {
            get => _billItems;
            set
            {
                _billItems = value;
                OnPropertyChanged(nameof(BillItems));
                CalculateTotalAmount();
            }
        }

        private decimal _totalAmount;
        public decimal TotalAmount
        {
            get => _totalAmount;
            set
            {
                _totalAmount = value;
                OnPropertyChanged(nameof(TotalAmount));
            }
        }

        private Table _selectedTable;

        public Table SelectedTable
        {
            get { return _selectedTable; }
            set
            {
                if (_selectedTable != value)
                {
                    _selectedTable = value;
                    OnPropertyChanged(nameof(SelectedTable));
                }
            }
        }

        private ObservableCollection<Table> _emptyTables;
        public ObservableCollection<Table> EmptyTables
        {
            get => _emptyTables;
            set
            {
                _emptyTables = value;
                OnPropertyChanged(nameof(EmptyTables));
            }
        }

        private Table _targetTable;
        public Table TargetTable
        {
            get => _targetTable;
            set
            {
                _targetTable = value;
                OnPropertyChanged(nameof(TargetTable));
                Debug.WriteLine($"TargetTable changed: {TargetTable?.ID}");
            }
        }

        // Commands
        public ICommand ProcessPaymentCommand { get; }
        public ICommand TransferTableCommand { get; }
        public ICommand ShowMenuCommand { get; }

        private readonly QlnhContext _dbContext;

        // Constructor
        public TableStateViewModel(QlnhContext dbContext)
        {
            _dbContext = dbContext;
            TitleOfBill = SelectedTable != null ? "Hóa đơn bàn " + SelectedTable.ID : "CHỌN 1 BÀN";
            BillItems = new ObservableCollection<BillItem>();
            Tables = new ObservableCollection<Table>();
            EmptyTables = new ObservableCollection<Table>();
            LoadTablesFromDatabase();
            ProcessPaymentCommand = new RelayCommand(ProcessPayment, CanExecuteCommands);
            TransferTableCommand = new RelayCommand(TransferTable, CanExecuteCommands);
            ShowMenuCommand = new RelayCommand(ShowMenu, CanShowMenu);
        }

        private void ShowMenu(object parameter)
        {
            var table = parameter as Table;
            if (table != null && table.TrangThai)
            {
                SelectedTable = table;
                LoadBillForSelectedTable(table);
                TitleOfBill = $"Hóa đơn bàn {table.ID}";
            }
        }


        private bool CanShowMenu(object parameter)
        {
            var table = parameter as Table;
            return table != null && table.TrangThai;
        }


        private void LoadTablesFromDatabase()
        {
            try
            {
                var tables = _dbContext.Bans.Select(b => new Table
                {
                    ID = b.Id,
                    TrangThai = b.TrangThai
                }).ToList();

                Tables.Clear();
                EmptyTables.Clear();
                foreach (var table in tables)
                {
                    Tables.Add(table);
                    if (!table.TrangThai)
                    {
                        EmptyTables.Add(table); 
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi tải dữ liệu bàn: {ex.Message}", "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }


        private void LoadBillForSelectedTable(Table selectedTable)
        {
            var bill = _dbContext.Hoadons
                                  .Where(h => h.Idban == selectedTable.ID && h.IsDeleted == false)
                                  .FirstOrDefault();
            //MessageBox.Show(bill.Idban.ToString() + SelectedTable.ID);
            if (bill != null)
            {
                TitleOfBill = $"Hóa đơn bàn {selectedTable.ID}";
                var billItems = _dbContext.Cthds
                                          .Where(c => c.IdhoaDon == bill.Id)
                                          .Join(_dbContext.Doanuongs, c => c.IddoAnUong, d => d.Id,
                                                (c, d) => new BillItem
                                                {
                                                    Name = d.TenDoAnUong,
                                                    Quantity = c.SoLuong,
                                                    Price = c.GiaMon
                                                }).ToList();

                BillItems.Clear();
                foreach (var item in billItems)
                {
                    BillItems.Add(item);  
                }
                CalculateTotalAmount();  
            }
            else
            {
                MessageBox.Show("Bàn chưa có hóa đơn.");
                BillItems.Clear();
                TotalAmount = 0;
            }
        }


        private void CalculateTotalAmount()
        {
            TotalAmount = BillItems.Sum(item => item.Quantity * item.Price);
        }

        private void ProcessPayment(object parameter)
        {
            if (SelectedTable == null)
            {
                MessageBox.Show("Vui lòng chọn bàn để thanh toán!");
                return;
            }

            try
            {
                var result = MessageBox.Show("Bạn có muốn xuất hóa đơn không?", "Xuất hóa đơn", MessageBoxButton.YesNo, MessageBoxImage.Question);

                if (result == MessageBoxResult.Yes)
                {
                    var saveFileDialog = new SaveFileDialog
                    {
                        Filter = "Excel Files (*.xlsx)|*.xlsx",
                        FileName = $"HoaDon_Ban{SelectedTable.ID}_Time_{DateTime.Now:yyyyMMddHHmmss}.xlsx"
                    };

                    if ((saveFileDialog.ShowDialog()) == true)
                    {
                        // Tiến hành xuất hóa đơn ra file Excel
                        ExportBillToExcel(saveFileDialog.FileName);
                    }
                }

                // Tiến hành thanh toán
                var paybill = _dbContext.Hoadons
                                         .Where(h => h.Idban == SelectedTable.ID && h.IsDeleted == false)
                                         .FirstOrDefault();
                var exbill = _dbContext.Hoadons
                                         .Where(h => h.Idban == SelectedTable.ID)
                                         .FirstOrDefault();

                if (exbill == null)
                {
                    MessageBox.Show("Bàn chưa có hóa đơn.");
                    BillItems.Clear();
                    TotalAmount = 0;
                    return;
                }

                if (exbill != null)
                {
                    if (paybill != null)
                    {
                        SelectedTable.TrangThai = false;
                        paybill.IsDeleted = true;
                        _dbContext.SaveChanges();

                        var ban = _dbContext.Bans.FirstOrDefault(b => b.Id == SelectedTable.ID);
                        if (ban != null)
                        {
                            ban.TrangThai = false;
                            _dbContext.SaveChanges();
                            SelectedTable.TrangThai = false;
                            OnPropertyChanged(nameof(SelectedTable));
                        }

                        MessageBox.Show("Thanh toán thành công!");
                        LoadTablesFromDatabase();
                        BillItems.Clear();
                        TotalAmount = 0;
                    }
                }
                else
                {
                    MessageBox.Show("Không có hóa đơn chưa thanh toán.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Lỗi khi thanh toán: {ex.Message}", "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ExportBillToExcel(string filePath)
        {
            var bill = _dbContext.Hoadons
                                 .Where(h => h.Idban == SelectedTable.ID && h.IsDeleted == false)
                                 .FirstOrDefault();

            if (bill != null)
            {
                var billItems = _dbContext.Cthds
                                          .Where(c => c.IdhoaDon == bill.Id)
                                          .Join(_dbContext.Doanuongs, c => c.IddoAnUong, d => d.Id,
                                                (c, d) => new BillItem
                                                {
                                                    Name = d.TenDoAnUong,
                                                    Quantity = c.SoLuong,
                                                    Price = c.GiaMon
                                                }).ToList();

                try
                {
                    using (var package = new ExcelPackage(new FileInfo(filePath)))
                    {
                        var worksheet = package.Workbook.Worksheets.Add("Hóa đơn");

                        // Thêm ngày giờ xuất hóa đơn
                        worksheet.Cells[1, 1].Value = $"Hóa đơn bàn {SelectedTable.ID}";
                        worksheet.Cells[2, 1].Value = $"Ngày xuất: {DateTime.Now:dd/MM/yyyy HH:mm:ss}";
                        worksheet.Cells[3, 1].Value = "Tên món";
                        worksheet.Cells[3, 2].Value = "Số lượng";
                        worksheet.Cells[3, 3].Value = "Giá";
                        worksheet.Cells[3, 4].Value = "Tổng";

                        decimal totalAmount = 0;
                        int row = 4;

                        // Dữ liệu hóa đơn
                        foreach (var item in billItems)
                        {
                            worksheet.Cells[row, 1].Value = item.Name;
                            worksheet.Cells[row, 2].Value = item.Quantity;
                            worksheet.Cells[row, 3].Value = item.Price;
                            worksheet.Cells[row, 4].Value = item.Quantity * item.Price;
                            totalAmount += item.Quantity * item.Price;
                            row++;
                        }

                        // Tổng tiền
                        worksheet.Cells[row, 3].Value = "Tổng tiền";
                        worksheet.Cells[row, 4].Value = totalAmount;

                        // Lưu file Excel
                        package.Save();
                    }

                    MessageBox.Show($"Hóa đơn đã được lưu vào: {filePath}", "Thành công", MessageBoxButton.OK, MessageBoxImage.Information);
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Lỗi khi xuất hóa đơn: {ex.Message}", "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                MessageBox.Show("Không có hóa đơn để xuất.");
            }
        }

        private void TransferTable(object parameter)
        {
            if (parameter is Table targetTable && SelectedTable != null)
            {
                var bill = _dbContext.Hoadons
                                     .FirstOrDefault(h => h.Idban == SelectedTable.ID && h.IsDeleted == false);

                if (bill != null && targetTable.TrangThai == false) 
                {
                    bill.Idban = targetTable.ID;
                    var oldTable = _dbContext.Bans.FirstOrDefault(b => b.Id == SelectedTable.ID);
                    if (oldTable != null)
                    {
                        oldTable.TrangThai = false;  
                        _dbContext.Bans.Update(oldTable);  
                    }

                    var targetBan = _dbContext.Bans.FirstOrDefault(b => b.Id == targetTable.ID);
                    if (targetBan != null)
                    {
                        targetBan.TrangThai = true;  
                        _dbContext.Bans.Update(targetBan); 
                    }

                    _dbContext.SaveChanges(); 

                    LoadTablesFromDatabase(); 
                    MessageBox.Show($"Chuyển bàn thành công từ bàn {SelectedTable.ID} sang bàn {targetTable.ID}!");
                }
                else
                {
                    MessageBox.Show("Bàn mục tiêu không trống hoặc không có hóa đơn để chuyển.");
                }
            }
            else
            {
                MessageBox.Show("No data!");
            }
        }




        private bool CanExecuteCommands(object parameter)
        {
            return SelectedTable != null; 
        }

        private void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public class BillItem
    {
        public int IDDoAnUong { get; set; }
        public string Name { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
    }

    public class Table
    {
        public int ID { get; set; }
        public bool TrangThai { get; set; } // Trạng thái: true = đã đặt, false = chưa đặt
    }
}