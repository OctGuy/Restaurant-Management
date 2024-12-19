using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Windows.Data;
using System.Windows.Input;
using RestaurantManagement.Models;
using static RestaurantManagement.ViewModels.MenuViewModel;
using System.Windows;
using Microsoft.EntityFrameworkCore;


namespace RestaurantManagement.ViewModels
{
    public class MenuViewModel : INotifyPropertyChanged
    {
        public ICommand OrderCommand { get; set; }
        public ICommand DeleteAllCommand { get; set; }
        public ICommand DeleteSelectedItemCommand { get; set; }

        public ICommand NotifyCookingCommand { get; set; }
        public MenuViewModel(QlnhContext context)
        {
            LoadDataFromDatabase();
            LoadMenuItems();
            ControlsEnabled = true;
            OrderCommand = new RelayCommand(OrderDish, CanExecute);
            DeleteSelectedItemCommand = new RelayCommand(DeleteSelectedItem, CanExecuteDelete);
            DeleteAllCommand = new RelayCommand(DeleteAll, CanExecuteDelete);
            NotifyCookingCommand = new RelayCommand(NotifyCooking, CanExecuteNotify);
            SelectedItems = new ObservableCollection<SelectedItem>();

        }

        //SEARCH
        private string _searchKeyword;
        public string SearchKeyword
        {
            get => _searchKeyword;
            set
            {
                if (_searchKeyword != value)
                {
                    _searchKeyword = value;
                    OnPropertyChanged(nameof(SearchKeyword));
                    MenuItemsView.Refresh();
                }
            }
        }
        private void MenuItems_Filter(object sender, FilterEventArgs e)
        {
            if (e.Item is Doanuong dish)
            {
                if (string.IsNullOrEmpty(SearchKeyword))
                {
                    e.Accepted = true;
                }
                else
                {
                    e.Accepted = dish.TenDoAnUong.ToLower().Contains(SearchKeyword.ToLower());
                }
            }
        }


        //TONG_TIEN
        private decimal _sum;
        public decimal SUM
        {
            get => _sum;
            set
            {
                if (_sum != value)
                {
                    _sum = value;
                    OnPropertyChanged(nameof(SUM));
                }
            }
        }

        private void UpdateSum()
        {
            SUM = SelectedItems.Sum(item => item.GiaMon * item.SoLuong);
        }

        //DELETE_ITEMS

        private void DeleteSelectedItem(object parameter)
        {
            if (parameter is SelectedItem itemToRemove)
            {
                using (var context = new QlnhContext())
                {
                    var hoaDon = context.Hoadons.FirstOrDefault(h => h.Idban == SelectedTable.Id);
                    if (hoaDon != null)
                    {
                        var doAnUong = context.Doanuongs.FirstOrDefault(d => d.Id == itemToRemove.IdDoAnUong);
                        if (doAnUong != null)
                        {
                            var chiTietHoaDon = context.Cthds.FirstOrDefault(c => c.IddoAnUong == doAnUong.Id && c.IdhoaDon == hoaDon.Id);
                            if (chiTietHoaDon != null)
                            {
                                context.Cthds.Remove(chiTietHoaDon);
                            }
                        }
                    }

                    context.SaveChanges();
                }

                SelectedItems.Remove(itemToRemove);
                UpdateSum();
            }
        }




        //Menu Items
        public ObservableCollection<Doanuong> MenuItemCollection { get; set; }

        public void LoadMenuItems()
        {
            using (var context = new QlnhContext())
            {
                var menuItems = context.Doanuongs.ToList();
                MenuItemCollection = new ObservableCollection<Doanuong>(menuItems);
            }
            InitializeMenuView();
        }
        //Day
        public string Day
        {
            get
            {
                return DateTime.Today.DayOfWeek.ToString() + ", " + DateTime.Now.ToString("dd/MM/yyyy");
            }
        }

        //TABLES
        public ObservableCollection<Ban> DanhSachBan { get; set; }

        public void LoadTablesFromDatabase()
        {
            using (var context = new QlnhContext())
            {
                var tables = context.Bans.ToList();
                DanhSachBan = new ObservableCollection<Ban>(tables);
            }
        }

        //ORDER
        public class OrderItem
        {
            public int Id { get; set; }
            public string TenDoAnUong { get; set; }
            public int SoLuong { get; set; }
            public decimal DonGia { get; set; }
        }

        private void OrderDish(object parameter)
        {
            if (parameter is Doanuong dish)
            {
                var existingItem = SelectedItems.FirstOrDefault(item => item.IdDoAnUong == dish.Id);

                if (existingItem != null)
                {
                    existingItem.SoLuong++;
                }
                else
                {
                    SelectedItems.Add(new SelectedItem
                    {
                        IdDoAnUong = dish.Id, 
                        TenDoAnUong = dish.TenDoAnUong,
                        GiaMon = dish.DonGia,
                        SoLuong = 1
                    });
                }
                UpdateSum();
                OnPropertyChanged(nameof(SelectedItems));
            }
        }

        private Ban _selectedTable;
        public Ban SelectedTable
        {
            get => _selectedTable;
            set
            {
                _selectedTable = value;
                OnPropertyChanged(nameof(SelectedTable));
                CommandManager.InvalidateRequerySuggested();
            }
        }

        //SELECTED ITEMS
        private ObservableCollection<SelectedItem> _selectedItems;
        public ObservableCollection<SelectedItem> SelectedItems
        {
            get => _selectedItems;
            set
            {
                _selectedItems = value;
                OnPropertyChanged(nameof(SelectedItems));
            }
        }

        public class SelectedItem : INotifyPropertyChanged
        {
            private string _tenDoAnUong;
            private decimal _giaMon;
            private int _soLuong;
            private string _thoiGian;
            public int IdDoAnUong { get; set; }
            public string ThoiGian
            {
                get => _thoiGian;
                set
                {
                    _thoiGian = value;
                    OnPropertyChanged(nameof(ThoiGian));
                }
            }

            public string TenDoAnUong
            {
                get => _tenDoAnUong;
                set
                {
                    _tenDoAnUong = value;
                    OnPropertyChanged(nameof(TenDoAnUong));
                }
            }

            public decimal GiaMon
            {
                get => _giaMon;
                set
                {
                    _giaMon = value;
                    OnPropertyChanged(nameof(GiaMon));
                }
            }

            public int SoLuong
            {
                get => _soLuong;
                set
                {
                    _soLuong = value;
                    OnPropertyChanged(nameof(SoLuong));
                }
            }

            public event PropertyChangedEventHandler PropertyChanged;
            protected void OnPropertyChanged(string propertyName)
            {
                PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
            }
        }

        private void LoadDataFromDatabase()
        {
            try
            {
                using (var context = new QlnhContext())
                {
                    var tables = context.Bans.ToList();
                    DanhSachBan = new ObservableCollection<Ban>(tables);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading data: {ex.Message}");
            }
        }

        //DELETE

        private void RemoveSelectedItems()
        {
            using (var context = new QlnhContext())
            {
                foreach (var item in SelectedItems)
                {
                    var doAnUong = context.Doanuongs.FirstOrDefault(d => d.TenDoAnUong == item.TenDoAnUong);
                    var hoaDon = context.Hoadons.FirstOrDefault(h => h.Idban == SelectedTable.Id);
                    if (doAnUong != null)
                    {
                        var chiTietHoaDon = context.Cthds.FirstOrDefault(c => c.IddoAnUong == doAnUong.Id && c.IdhoaDon == hoaDon.Id);
                        if (chiTietHoaDon != null)
                        {
                            context.Cthds.Remove(chiTietHoaDon);
                        }
                    }
                }
                context.SaveChanges();
            }
            SelectedItems.Clear();
            MessageBox.Show("Các món ăn đã được xóa thành công!", "Thông báo", MessageBoxButton.OK, MessageBoxImage.Information);
        }

        private void DeleteAllSelectedItems(object parameter)
        {
            SelectedItems.Clear();
            UpdateSum();
            OnPropertyChanged(nameof(SelectedItems));
        }
        private void DeleteAll(object parameter)
        {
            RemoveSelectedItems(); 
            SelectedItems.Clear();
            UpdateSum();
        }

        ////SORT
        private readonly CollectionViewSource _menuItemsView = new CollectionViewSource();
        private string _myComboboxSelection = "A -> Z";
        public ObservableCollection<string> ComboBoxItems { get; set; } = new ObservableCollection<string>
        {
            "A -> Z",
            "Z -> A",
            "Giá thấp -> cao",
            "Giá cao -> thấp"
        };
        public string MyComboboxSelection
        {
            get => _myComboboxSelection;
            set
            {
                _myComboboxSelection = value;
                OnPropertyChanged(nameof(MyComboboxSelection));
                SortMenuItems();
            }
        }
        public void SortMenuItems()
        {
            _menuItemsView.SortDescriptions.Clear();

            if (MyComboboxSelection == "Giá cao -> thấp")
            {
                _menuItemsView.SortDescriptions.Add(new SortDescription("DonGia", ListSortDirection.Descending));
            }
            else if (MyComboboxSelection == "Giá thấp -> cao")
            {
                _menuItemsView.SortDescriptions.Add(new SortDescription("DonGia", ListSortDirection.Ascending));
            }
            else if (MyComboboxSelection == "A -> Z")
            {
                _menuItemsView.SortDescriptions.Add(new SortDescription("TenDoAnUong", ListSortDirection.Ascending));
            }
            else if (MyComboboxSelection == "Z -> A")
            {
                _menuItemsView.SortDescriptions.Add(new SortDescription("TenDoAnUong", ListSortDirection.Descending));
            }
            MenuItemsView.Refresh();
        }

        public ICollectionView MenuItemsView => _menuItemsView.View;

        private void InitializeMenuView()
        {
            _menuItemsView.Source = MenuItemCollection;
            _menuItemsView.Filter += MenuItems_Filter;
            _menuItemsView.SortDescriptions.Add(new SortDescription("TenDoAnUong", ListSortDirection.Ascending));
        }

        //BAO CHE BIEN
        private void NotifyCooking(object parameter)
        {
            if (SelectedTable != null && SelectedItems.Any())
            {
                try
                {
                    using (var context = new QlnhContext())
                    {
                        var table = context.Bans.FirstOrDefault(b => b.Id == SelectedTable.Id);
                        //MessageBox.Show(table.Id.ToString() + SelectedTable.Id.ToString());
                        table.TrangThai = true;
                        context.Bans.Update(table);

                        var hoaDon = context.Hoadons.FirstOrDefault(h => h.Idban == SelectedTable.Id && h.IsDeleted == false);
                        if (hoaDon == null)
                        {
                            hoaDon = new Hoadon
                            { 
                                Idban = SelectedTable.Id,
                                IdnhanVien = 2,
                                NgayHoaDon = DateTime.Now,
                                TongGia = SUM,
                                IsDeleted = false,
                            };
                            context.Hoadons.Add(hoaDon);  
                            context.SaveChanges(); 
                        }
                        else
                        {
                            hoaDon.TongGia = SUM;
                        }

                        if (hoaDon.Id > 0)
                        {
                            var cheBien = new Chebien
                            {
                                IdhoaDon = hoaDon.Id,
                                ThoiGianChuanBi = 0
                            };
                            context.Chebiens.Add(cheBien);
                        }



                        foreach (var item in SelectedItems)
                        {
                            var doAnUong = context.Doanuongs.FirstOrDefault(d => d.Id == item.IdDoAnUong);

                            if (doAnUong != null)
                            {
                                var existingDish = context.Cthds.FirstOrDefault(e => e.IdhoaDon == hoaDon.Id && e.IddoAnUong == doAnUong.Id);
                                if (existingDish == null)
                                {
                                    var chiTietHoaDon = new Cthd
                                    {
                                        IdhoaDon = hoaDon.Id,
                                        IddoAnUong = doAnUong.Id,
                                        SoLuong = item.SoLuong,
                                        GiaMon = item.GiaMon
                                    };
                                    context.Cthds.Add(chiTietHoaDon);
                                }
                                else
                                {
                                    existingDish.SoLuong += item.SoLuong; 
                                }
                            }
                        }

                        context.SaveChanges();
                        LoadDataFromDatabase();
                        MessageBox.Show($"Đã gửi thông báo chế biến cho bàn {SelectedTable.Id}!", "Thông báo", MessageBoxButton.OK, MessageBoxImage.Information);
                        SelectedItems.Clear();
                        UpdateSum();
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Có lỗi xảy ra khi gửi chế biến: {ex.Message}", "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                MessageBox.Show("Vui lòng chọn bàn và ít nhất một món để gửi thông báo chế biến.", "Cảnh báo", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
        }


        private bool _controlsEnabled;
        public bool ControlsEnabled
        {
            get => _controlsEnabled;
            set
            {
                _controlsEnabled = value;
                OnPropertyChanged(nameof(ControlsEnabled));
            }
        }

        //CAN_EXECUTE
        private bool CanExecute(object parameter)
        {
            return ControlsEnabled && SelectedTable != null && parameter is Doanuong;
        }

        private bool CanExecuteDelete(object parameter) => ControlsEnabled;
        private bool CanExecuteNotify(object parameter) => ControlsEnabled;

        public event PropertyChangedEventHandler PropertyChanged;
        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public class RelayCommand : ICommand
    {
        private readonly Action<object> _execute;
        private readonly Func<object, bool> _canExecute;
        public RelayCommand(Action<object> execute, Func<object, bool> canExecute = null)
        {
            _execute = execute ?? throw new ArgumentNullException(nameof(execute));
            _canExecute = canExecute;
        }
        public bool CanExecute(object parameter) => _canExecute?.Invoke(parameter) ?? true;
        public void Execute(object parameter) => _execute(parameter);
        public event EventHandler CanExecuteChanged
        {
            add => CommandManager.RequerySuggested += value;
            remove => CommandManager.RequerySuggested -= value;
        }
        public void RaiseCanExecuteChanged()
        {
            CommandManager.InvalidateRequerySuggested();
        }
    }

}