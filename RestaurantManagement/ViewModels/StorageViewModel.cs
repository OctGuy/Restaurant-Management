using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using RestaurantManagement.Models;
using RestaurantManagement.Views;
using System.Collections.ObjectModel;
using System.Runtime.Intrinsics.Arm;
using System.Windows.Input;
using System.Windows;
using System.IO;
using System.Windows.Forms;
using System.Windows.Media.Imaging;
using RestaurantManagement;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualBasic;
using Microsoft.EntityFrameworkCore.Diagnostics;
using System.DirectoryServices;
using Microsoft.EntityFrameworkCore.Query.Internal;
using System.Windows.Data;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace RestaurantManagement.ViewModels
{
    public class StorageViewModel : BaseViewModel
    {
        private readonly QlnhContext dbContext;
        public class Ingredient
        {
            public int importID { get; set; }
            public int ingredientID { get; set; }
            public string? ingredientName { get; set; }
            public DateTime? supplyDate { get; set; }
            public string? unit { get; set; }
            public decimal? unitPrice { get; set; }
            public int? quantity { get; set; }
            public bool type { get; set; } // 0: raw, 1: drink
            public string? supplySource { get; set; }
            public string? phoneNumber { get; set; }
            public int? remainQuantity { get; set; }
        }

        public ICommand ResetFilterCommand { get; set; }
        public ICommand OpenEditCommand { get; set; }
        public ICommand ImportIngredientCommand { get; set; }
        public ICommand DeleteIngredientCommand { get; set; }
        //public ICommand 

        private ObservableCollection<Ingredient> rawIngrdients;
        public ObservableCollection<Ingredient> RawIngredients
        {
            get => rawIngrdients;
            set
            {
                rawIngrdients = value;
                OnPropertyChanged(); 
            }
        }

        private ObservableCollection<Ingredient> displayRawIngredients;
        public ObservableCollection<Ingredient> DisplayRawIngredients
        {
            get => displayRawIngredients;
            set
            {
                displayRawIngredients = value;
                OnPropertyChanged();
            }
        }

        private ObservableCollection<Ingredient> drinkIngrdients;
        public ObservableCollection<Ingredient> DrinkIngredients
        {
            get => drinkIngrdients;
            set
            {
                drinkIngrdients = value;
                OnPropertyChanged();
            }
        }

        private ObservableCollection<Ingredient> displayDrinkIngredients;
        public ObservableCollection<Ingredient> DisplayDrinkIngredients
        {
            get => displayDrinkIngredients;
            set
            {
                displayDrinkIngredients = value;
                OnPropertyChanged();
            }
        }

        private Ingredient selectedRawIngredient;
        public Ingredient SelectedRawIngredient
        {
            get => selectedRawIngredient;
            set
            {
                selectedRawIngredient = value;
                OnPropertyChanged();
            }
        }

        private Ingredient selectedDrinkIngredient;
        public Ingredient SelectedDrinkIngredient
        {
            get => selectedDrinkIngredient;
            set
            {
                selectedDrinkIngredient = value;
                OnPropertyChanged();
            }
        }

        private string ingredientNameFilter;
        public string IngredientNameFilter
        {
            get => ingredientNameFilter;
            set
            {
                ingredientNameFilter = value;
                OnPropertyChanged(nameof(IngredientNameFilter));
                ApplyFilterRaw();
                ApplyFilterDrink();
            }
        }

        private int? selectedDay;
        private int? selectedMonth;
        private int? selectedYear;

        public int? SelectedDay
        {
            get => selectedDay;
            set
            {
                selectedDay = value;
                OnPropertyChanged(nameof(SelectedDay));
                ApplyFilterRaw();
                ApplyFilterDrink();
            }
        }

        public int? SelectedMonth
        {
            get => selectedMonth;
            set
            {
                selectedMonth = value;
                OnPropertyChanged(nameof(SelectedMonth));
                UpdateDays();
                ApplyFilterRaw();
                ApplyFilterDrink();
            }
        }

        public int? SelectedYear
        {
            get => selectedYear;
            set
            {
                selectedYear = value;
                OnPropertyChanged(nameof(SelectedYear));
                UpdateDays();
                ApplyFilterRaw();
                ApplyFilterDrink();
            }
        }

        private Ingredient addedIngredient;
        public Ingredient AddedIngredient
        {
            get => addedIngredient;
            set
            {
                addedIngredient = value;
                OnPropertyChanged();
            }
        }

        public List<int> Years { get; }
        public List<int> Months { get; }
        public ObservableCollection<int> Days { get; }

        public ObservableCollection<string> ingredientType { get; }

        private string selectedIngredientType;
        public string SelectedIngredientType
        {
            get => selectedIngredientType;
            set
            {
                selectedIngredientType = value;
                OnPropertyChanged();
            }
        }

        public void LoadRawIngredients()
        {
            try
            {
                var latestEntries = dbContext.Nhapkhos
                                .Where(nk => nk.IsDeleted == false && nk.Idkho == 1)
                                .SelectMany(nk => nk.Ctnhapkhos, (nk, ctnk) => new { nk, ctnk })
                                .Where(x => x.ctnk.IdnguyenLieuNavigation.IsDeleted == false)
                                .GroupBy(result => result.ctnk.IdnguyenLieu)
                                .Select(group => group
                                    .OrderByDescending(g => g.nk.NgayNhap)
                                    .Select(g => new
                                    {
                                        g.nk.Id,
                                        g.nk.NgayNhap,
                                        g.ctnk.IdnguyenLieu,
                                        g.ctnk.SoLuongNguyenLieu,
                                        g.nk.NguonNhap,
                                        g.nk.SdtlienLac,
                                        g.ctnk.IdnguyenLieuNavigation.TenNguyenLieu,
                                        g.ctnk.IdnguyenLieuNavigation.DonVi,
                                        g.ctnk.IdnguyenLieuNavigation.DonGia
                                    })
                                    .FirstOrDefault())
                                .ToList();

                RawIngredients = new ObservableCollection<Ingredient>(
                    latestEntries.Select(result => new Ingredient
                    {
                        importID = result.Id,
                        ingredientID = result.IdnguyenLieu,
                        ingredientName = result.TenNguyenLieu,
                        supplyDate = result.NgayNhap,
                        unit = result.DonVi,
                        unitPrice = result.DonGia,
                        quantity = result.SoLuongNguyenLieu,
                        type = false,
                        supplySource = result.NguonNhap,
                        phoneNumber = result.SdtlienLac,
                        remainQuantity = dbContext.Ctkhos
                                                   .Where(ctk => ctk.Idkho == 1 && ctk.IdnguyenLieu == result.IdnguyenLieu)
                                                   .Select(ctk => ctk.SoLuongTonDu)
                                                   .FirstOrDefault()
                    }));

                DisplayRawIngredients = new ObservableCollection<Ingredient>(RawIngredients);
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show($"Lỗi khi tải dữ liệu của Kho nguyên liệu thô: {ex.Message}\nChi tiết: {ex.InnerException?.Message}");
            }
        }

        public void LoadDrinkIngredients()
        {
            try
            {
                var latestEntries = dbContext.Nhapkhos
                                .Where(nk => nk.IsDeleted == false && nk.Idkho == 2)
                                .SelectMany(nk => nk.Ctnhapkhos, (nk, ctnk) => new { nk, ctnk })
                                .Where(x => x.ctnk.IdnguyenLieuNavigation.IsDeleted == false)
                                .GroupBy(result => result.ctnk.IdnguyenLieu)
                                .Select(group => group
                                    .OrderByDescending(g => g.nk.NgayNhap)
                                    .Select(g => new
                                    {
                                        g.nk.Id,
                                        g.nk.NgayNhap,
                                        g.ctnk.IdnguyenLieu,
                                        g.ctnk.SoLuongNguyenLieu,
                                        g.nk.NguonNhap,
                                        g.nk.SdtlienLac,
                                        g.ctnk.IdnguyenLieuNavigation.TenNguyenLieu,
                                        g.ctnk.IdnguyenLieuNavigation.DonVi,
                                        g.ctnk.IdnguyenLieuNavigation.DonGia
                                    })
                                    .FirstOrDefault())
                                .ToList();

                DrinkIngredients = new ObservableCollection<Ingredient>(
                    latestEntries.Select(result => new Ingredient
                    {
                        importID = result.Id,
                        ingredientID = result.IdnguyenLieu,
                        ingredientName = result.TenNguyenLieu,
                        supplyDate = result.NgayNhap,
                        unit = result.DonVi,
                        unitPrice = result.DonGia,
                        quantity = result.SoLuongNguyenLieu,
                        type = false,
                        supplySource = result.NguonNhap,
                        phoneNumber = result.SdtlienLac,
                        remainQuantity = dbContext.Ctkhos
                                                   .Where(ctk => ctk.Idkho == 2 && ctk.IdnguyenLieu == result.IdnguyenLieu)
                                                   .Select(ctk => ctk.SoLuongTonDu)
                                                   .FirstOrDefault()
                    }));

                DisplayDrinkIngredients = new ObservableCollection<Ingredient>(DrinkIngredients);
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show($"Lỗi khi tải dữ liệu của Kho nước uống: {ex.Message}\nChi tiết: {ex.InnerException?.Message}");
            }
            
        }

        public StorageViewModel()
        {
            dbContext = new QlnhContext();
            LoadRawIngredients();
            LoadDrinkIngredients();

            Years = Enumerable.Range(2000, DateTime.Now.Year - 2000 + 1).ToList();
            Months = Enumerable.Range(1, 12).ToList();
            Days = new ObservableCollection<int>();
            ingredientType = new ObservableCollection<string> { "Nguyên liệu thô", "Nước uống" };

            ResetFilterCommand = new RelayCommand(ResetFilter);
            OpenEditCommand = new RelayCommand<object>(CanExecuteOpenEditView, ExecuteOpenEditView);
            DeleteIngredientCommand = new RelayCommand<object>(CanExecuteDeleteIngredient, ExecuteDeleteIngredient);
            ImportIngredientCommand = new RelayCommand(ImportIngredient);
            AddedIngredient = new Ingredient();
        }

        private void UpdateDays()
        {
            Days.Clear();
            if (SelectedYear > 0 && SelectedMonth > 0)
            {
                int daysInMonth = DateTime.DaysInMonth(SelectedYear.Value, SelectedMonth.Value);
                for (int i = 1; i <= daysInMonth; i++)
                    Days.Add(i);
            }
        }

        private void ApplyFilterRaw()
        {
            try
            {
                if (RawIngredients == null || !RawIngredients.Any()) return;

                var queryRaw = RawIngredients.AsEnumerable();

                if (!string.IsNullOrWhiteSpace(IngredientNameFilter))
                {
                    queryRaw = queryRaw.Where(q => q.ingredientName?.IndexOf(ingredientNameFilter, StringComparison.OrdinalIgnoreCase) >= 0);
                }

                if (SelectedYear > 0)
                {
                    queryRaw = queryRaw.Where(m => m.supplyDate?.Year == SelectedYear);
                }

                if (SelectedMonth > 0)
                {
                    queryRaw = queryRaw.Where(m => m.supplyDate?.Month == SelectedMonth);
                }

                if (SelectedDay > 0)
                {
                    queryRaw = queryRaw.Where(m => m.supplyDate?.Day == SelectedDay);
                }

                DisplayRawIngredients = new ObservableCollection<Ingredient>(queryRaw);
            }
            catch (Exception ex) 
            {
                System.Windows.Forms.MessageBox.Show($"Lỗi khi lọc Kho nguyên liệu thô: {ex.Message}\nChi tiết: {ex.InnerException?.Message}");
            }
        }

        private void ApplyFilterDrink()
        {
            try
            {
                if (DrinkIngredients == null || !DrinkIngredients.Any()) return;

                var queryDrink = DrinkIngredients.AsEnumerable();

                if (!string.IsNullOrWhiteSpace(IngredientNameFilter))
                {
                    queryDrink = queryDrink.Where(q => q.ingredientName?.IndexOf(ingredientNameFilter, StringComparison.OrdinalIgnoreCase) >= 0);
                }

                if (SelectedYear > 0)
                {
                    queryDrink = queryDrink.Where(m => m.supplyDate?.Year == SelectedYear);
                }

                if (SelectedMonth > 0)
                {
                    queryDrink = queryDrink.Where(m => m.supplyDate?.Month == SelectedMonth);
                }

                if (SelectedDay > 0)
                {
                    queryDrink = queryDrink.Where(m => m.supplyDate?.Day == SelectedDay);
                }

                DisplayDrinkIngredients = new ObservableCollection<Ingredient>(queryDrink);
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show($"Lỗi khi lọc Kho nước uống: {ex.Message}\nChi tiết: {ex.InnerException?.Message}");
            }
        }

        private void ResetFilter(object? parameter)
        {
            IngredientNameFilter = string.Empty;
            SelectedYear = null;
            SelectedMonth = null;
            SelectedDay = null;
            DisplayRawIngredients = new ObservableCollection<Ingredient>(RawIngredients);
            DisplayDrinkIngredients = new ObservableCollection<Ingredient>(DrinkIngredients);
        }

        private bool CanExecuteOpenEditView(object? parameter)
        {
            if (SelectedDrinkIngredient == null && SelectedRawIngredient == null)
                return false;
            return true;
        }

        private void ResetImportIngredient()
        {
            AddedIngredient.ingredientName = string.Empty;
            AddedIngredient.supplyDate = DateTime.Today;
            AddedIngredient.quantity = 0;
            AddedIngredient.unit = string.Empty;
            AddedIngredient.unitPrice = 0;
            AddedIngredient.phoneNumber = string.Empty;
            AddedIngredient.supplySource = string.Empty;    
        }

        private void ExecuteOpenEditView(object? parameter)
        {
            if (SelectedRawIngredient != null)
            {
                var editWindow = new EditIngredientView();
                var editViewModel = new EditIngredientViewModel(dbContext, SelectedRawIngredient, editWindow.Close);

                editWindow.DataContext = editViewModel;
                editWindow.ShowDialog();

                LoadRawIngredients();
            }

            if (SelectedDrinkIngredient != null)
            {
                var editWindow = new EditIngredientView();
                var editViewModel = new EditIngredientViewModel(dbContext, SelectedDrinkIngredient, editWindow.Close);

                editWindow.DataContext = editViewModel;
                editWindow.ShowDialog();

                LoadDrinkIngredients();
            }
        }

        private void ImportIngredient(object? parameter)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(AddedIngredient.ingredientName))
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng nhập tên nguyên liệu");
                    return;
                }

                if (!AddedIngredient.ingredientName.All(c => char.IsLetterOrDigit(c) || char.IsWhiteSpace(c)))
                {
                    System.Windows.Forms.MessageBox.Show("Tên nguyên liệu không được chứa ký tự đặc biệt");
                    return;
                }

                if (AddedIngredient.supplyDate == null)
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng chọn ngày nhập kho");
                    return;
                }

                var existingIngredient = dbContext.Nguyenlieus.FirstOrDefault(nl => nl.TenNguyenLieu == AddedIngredient.ingredientName && nl.IsDeleted == false);
                if (existingIngredient != null)
                {
                    // Tìm lần nhập kho gần nhất của nguyên liệu được thêm để so sánh ngày nhập kho với nhau
                    var latestNhapKho = dbContext.Nhapkhos
                            .Where(nk => nk.Idkho == (SelectedIngredientType == "Nguyên liệu thô" ? 1 : 2)
                                         && dbContext.Ctnhapkhos.Any(ctnk => ctnk.IdnhapKho == nk.Id && ctnk.IdnguyenLieu == existingIngredient.Id))
                            .OrderByDescending(nk => nk.NgayNhap)
                            .FirstOrDefault();

                    if (latestNhapKho != null && AddedIngredient.supplyDate <= latestNhapKho.NgayNhap)
                    {
                        System.Windows.Forms.MessageBox.Show("Ngày nhập kho lần này phải lớn hơn ngày nhập kho lần trước.");
                        return;
                    }
                }

                if (!int.TryParse(AddedIngredient.quantity?.ToString(), out var quantity) || quantity <= 0)
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng nhập lại số lượng");
                    return;
                }

                if (string.IsNullOrWhiteSpace(AddedIngredient.unit))
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng nhập đơn vị");
                    return;
                }

                if (!decimal.TryParse(AddedIngredient.unitPrice?.ToString(), out var unitPrice) || unitPrice <= 0)
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng nhập lại đơn giá");
                    return;
                }

                if (string.IsNullOrWhiteSpace(SelectedIngredientType))
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng chọn loại nguyên liệu");
                    return;
                }

                if (string.IsNullOrWhiteSpace(AddedIngredient.supplySource))
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng nhập nguồn cung cấp");
                    return;
                }

                if (!AddedIngredient.supplySource.All(c => char.IsLetterOrDigit(c) || char.IsWhiteSpace(c)))
                {
                    System.Windows.Forms.MessageBox.Show("Nguồn cung cấp không được chứa ký tự đặc biệt");
                    return;
                }

                if (string.IsNullOrWhiteSpace(AddedIngredient.phoneNumber))
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng nhập số điện thoại");
                    return;
                }

                if (!AddedIngredient.phoneNumber.All(char.IsDigit))
                {
                    System.Windows.Forms.MessageBox.Show("Số điện thoại chỉ được chứa các chữ số");
                    return;
                }

                decimal? giaNhap = AddedIngredient.quantity * AddedIngredient.unitPrice;

                // Hiển thị MessageBox để xác nhận Giá Nhập
                var result = System.Windows.Forms.MessageBox.Show(
                    $"Giá nhập cho lần nhập này là: {giaNhap}.\nBạn có đồng ý tiếp tục không?",
                    "Xác nhận Giá Nhập",
                    System.Windows.Forms.MessageBoxButtons.OKCancel,
                    System.Windows.Forms.MessageBoxIcon.Question);

                if (result == System.Windows.Forms.DialogResult.OK)
                {
                    var existingingredient = dbContext.Nguyenlieus.FirstOrDefault(nl => nl.TenNguyenLieu == AddedIngredient.ingredientName
                                                                                    && nl.IsDeleted == false);

                    if (existingingredient != null) // Nếu nguyên liệu đã có trong kho
                    {
                        existingingredient.DonGia = AddedIngredient.unitPrice;

                        // Cập nhật lượng tồn dư cho CTKHO
                        var updateCtkho = dbContext.Ctkhos.FirstOrDefault(ctk => ctk.IdnguyenLieu == existingingredient.Id);
                        if (updateCtkho != null)
                        {
                            updateCtkho.SoLuongTonDu += AddedIngredient.quantity;
                        }
                        dbContext.SaveChanges();


                        // Cập nhật NHAPKHO
                        var newNhapKho = new Nhapkho
                        {
                            NguonNhap = AddedIngredient.supplySource,
                            NgayNhap = AddedIngredient.supplyDate,
                            GiaNhap = AddedIngredient.quantity * AddedIngredient.unitPrice,
                            SdtlienLac = AddedIngredient.phoneNumber,
                            Idkho = SelectedIngredientType == "Nguyên liệu thô" ? 1 : 2,
                        };
                        dbContext.Nhapkhos.Add(newNhapKho);
                        dbContext.SaveChanges(); // Lưu để lấy Id nhập kho mới

                        int newIdNhapkho = newNhapKho.Id; // Lấy Id nhập kho mới


                        // Cập nhật CTNHAPKHO
                        var newCTNHAPKHO = new Ctnhapkho
                        {
                            IdnhapKho = newIdNhapkho,
                            IdnguyenLieu = existingingredient.Id,
                            SoLuongNguyenLieu = AddedIngredient.quantity,
                            GiaNguyenLieu = AddedIngredient.unitPrice * AddedIngredient.quantity
                        };
                        dbContext.Ctnhapkhos.Add(newCTNHAPKHO);
                        dbContext.SaveChanges();
                    }
                    else // Thêm nguyên liệu mới vào kho
                    {
                        // Thêm vào NGUYENLIEU
                        var newIngredient = new Nguyenlieu
                        {
                            TenNguyenLieu = AddedIngredient.ingredientName,
                            DonVi = AddedIngredient.unit,
                            DonGia = AddedIngredient.unitPrice,
                            TinhTrang = true
                        };
                        dbContext.Add(newIngredient);
                        dbContext.SaveChanges();

                        int newIngredientID = newIngredient.Id; // Lấy ID Nguyên liệu


                        // Thêm vào NHAPKHO
                        var newNhapKho = new Nhapkho
                        {
                            NguonNhap = AddedIngredient.supplySource,
                            NgayNhap = AddedIngredient.supplyDate,
                            GiaNhap = AddedIngredient.quantity * AddedIngredient.unitPrice,
                            SdtlienLac = AddedIngredient.phoneNumber,
                            Idkho = SelectedIngredientType == "Nguyên liệu thô" ? 1 : 2,
                        };
                        dbContext.Nhapkhos.Add(newNhapKho);
                        dbContext.SaveChanges();

                        int newNhapKhoID = newNhapKho.Id;


                        // Thêm vào CTNHAPKHO
                        var newCtnhapKho = new Ctnhapkho
                        {
                            IdnhapKho = newNhapKhoID,
                            IdnguyenLieu = newIngredientID,
                            SoLuongNguyenLieu = AddedIngredient.quantity,
                            GiaNguyenLieu = AddedIngredient.quantity * AddedIngredient.unitPrice
                        };
                        dbContext.Ctnhapkhos.Add(newCtnhapKho);
                        dbContext.SaveChanges();

                        // Thêm vào CTKHO
                        var newCtkho = new Ctkho
                        {
                            Idkho = SelectedIngredientType == "Nguyên liệu thô" ? 1 : 2,
                            IdnguyenLieu = newIngredientID,
                            SoLuongTonDu = AddedIngredient.quantity,
                        };
                        dbContext.Ctkhos.Add(newCtkho);
                        dbContext.SaveChanges();
                    }

                    LoadRawIngredients();
                    LoadDrinkIngredients();
                    // ResetImportIngredient();

                    System.Windows.Forms.MessageBox.Show("NHẬP KHO THÀNH CÔNG");
                }
            }
            catch(Exception ex)
            {
                System.Windows.Forms.MessageBox.Show($"Lỗi khi nhập kho: {ex.Message}\nChi tiết: {ex.InnerException?.Message}");
            }
        }

        private bool CanExecuteDeleteIngredient(object? parameter)
        {
            if (SelectedDrinkIngredient == null && SelectedRawIngredient == null)
                return false;
            return true;
        }

        private void ExecuteDeleteIngredient(object? parameter)
        {
            if (SelectedRawIngredient != null)
            {
                var result = System.Windows.Forms.MessageBox.Show(
                    $"Bạn có đồng ý xóa nguyên liệu không?",
                    "Xác nhận xóa",
                    System.Windows.Forms.MessageBoxButtons.OKCancel,
                    System.Windows.Forms.MessageBoxIcon.Question);

                try
                {
                    if (result == System.Windows.Forms.DialogResult.OK)
                    {
                        var existingIngredient = dbContext.Nguyenlieus.FirstOrDefault(nl => nl.Id == SelectedRawIngredient.ingredientID);

                        if (existingIngredient != null)
                        {
                            existingIngredient.IsDeleted = true;
                            var ctkho = dbContext.Ctkhos.FirstOrDefault(ctk => ctk.IdnguyenLieu == SelectedRawIngredient.ingredientID);
                            if (ctkho != null)
                            {
                                ctkho.IsDeleted = true;
                            }

                            dbContext.SaveChanges();
                            System.Windows.Forms.MessageBox.Show($"Xóa {SelectedRawIngredient.ingredientName} thành công");
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Windows.Forms.MessageBox.Show($"Lỗi khi xóa nguyên liệu thô: {ex.Message}\nChi tiết: {ex.InnerException?.Message}");
                }
            }

            if (SelectedDrinkIngredient != null)
            {
                var result = System.Windows.Forms.MessageBox.Show(
                    $"Bạn có đồng ý xóa nguyên liệu không?",
                    "Xác nhận xóa",
                    System.Windows.Forms.MessageBoxButtons.OKCancel,
                    System.Windows.Forms.MessageBoxIcon.Question);

                try
                {
                    if (result == System.Windows.Forms.DialogResult.OK)
                    {
                        var existingIngredient = dbContext.Nguyenlieus.FirstOrDefault(nl => nl.Id == SelectedDrinkIngredient.ingredientID);

                        if (existingIngredient != null)
                        {
                            existingIngredient.IsDeleted = true;
                            var ctkho = dbContext.Ctkhos.FirstOrDefault(ctk => ctk.IdnguyenLieu == SelectedDrinkIngredient.ingredientID);
                            if (ctkho != null)
                            {
                                ctkho.IsDeleted = true;
                            }

                            dbContext.SaveChanges();
                            System.Windows.Forms.MessageBox.Show($"Xóa {SelectedDrinkIngredient.ingredientName} thành công");
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Windows.Forms.MessageBox.Show($"Lỗi khi xóa nước uống: {ex.Message}\nChi tiết: {ex.InnerException?.Message}");
                }
            }

            LoadRawIngredients();
            LoadDrinkIngredients();
        }
    }
}