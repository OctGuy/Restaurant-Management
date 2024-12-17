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
using static RestaurantManagement.ViewModels.AddIngredientViewModel;
using System.Windows.Media;
using System.Windows.Data;
using System.ComponentModel;
using Diacritics.Extensions;

namespace RestaurantManagement.ViewModels
{
    public class FoodMenuViewModel : BaseViewModel
    {
        private readonly QlnhContext dbContext; // Manipulating database

        #region declare commands

        public ICommand AddDishesCommand { get; set; }
        public ICommand SwitchToAddDishesViewCommand { get; set; }
        public ICommand DeleteDishesCommand { get; set; }
        public ICommand ViewIngredientsCommand { get; set; }
        public ICommand EditDishImageCommand { get; set; }
        public ICommand AddDishImageCommand { get; set; }
        public ICommand SelectedDishCommand { get; set; }

        #endregion

        private ObservableCollection<Doanuong> _listDishes;
        public ObservableCollection<Doanuong> ListDishes
        {
            get => _listDishes;
            set
            {
                _listDishes = value;
                OnPropertyChanged();
            }
        }

        private ObservableCollection<Doanuong> displayListDishes;
        public ObservableCollection<Doanuong> DisplayListDishes
        {
            get => displayListDishes;
            set
            {
                displayListDishes = value;
                OnPropertyChanged();
            }
        }

        private bool isChange = false;

        private Doanuong _selectedDish;
        public Doanuong SelectedDish
        {
            get => _selectedDish;
            set
            {
                _selectedDish = value;
                OnPropertyChanged();

                if (_selectedDish != null && _selectedDish.AnhDoAnUong != null)
                {
                    var converter = new ImageConverter();
                    EditedImage = converter.ByteArrayToBitmapImage(_selectedDish.AnhDoAnUong);
                }
            }
        }

        private Visibility _editView;
        public Visibility EditView
        {
            get
            {
                return _editView;
            }
            set
            {
                _editView = value;
                OnPropertyChanged();
            }
        }

        private Visibility _addView;
        public Visibility AddView
        {
            get
            {
                return _addView;
            }
            set
            {
                _addView = value;
                OnPropertyChanged();
            }
        }

        private Doanuong _addedDish;
        public Doanuong AddedDish
        {
            get => _addedDish;
            set
            {
                _addedDish = value;
                OnPropertyChanged();
            }
        }

        public ObservableCollection<string> DishType { get; set; } = new ObservableCollection<string> { "Đồ ăn", "Thức uống" };

        private string _selectedDishType;
        public string SelectedDishType
        {
            get => _selectedDishType;
            set
            {
                _selectedDishType = value;
                OnPropertyChanged();
            }
        }

        private BitmapImage addedImage;
        public BitmapImage AddedImage
        {
            get => addedImage;
            set
            {
                addedImage = value;
                OnPropertyChanged(nameof(AddedImage));
            }
        }

        private BitmapImage editedImage;
        public BitmapImage EditedImage
        {
            get => editedImage;
            set
            {
                editedImage = value;
                OnPropertyChanged(nameof(EditedImage));
            }
        }

        private string foodMenuFilterText;
        public string FoodMenuFilterText
        {
            get => foodMenuFilterText;
            set
            {
                foodMenuFilterText = value;
                OnPropertyChanged(nameof(FoodMenuFilterText));
                FoodMenu_Filter();
            }
        }

        public FoodMenuViewModel()
        {
            dbContext = new QlnhContext();
            LoadData();
            InitializeCommands();
        }

        private void LoadData()
        {
            ListDishes = new ObservableCollection<Doanuong>(dbContext.Doanuongs.ToList());
            DisplayListDishes = new ObservableCollection<Doanuong>(ListDishes);
        }

        private void InitializeCommands()
        {
            AddedDish = new Doanuong();
            AddDishesCommand = new RelayCommand(AddDishes);
            SwitchToAddDishesViewCommand = new RelayCommand<object>(CanExecuteSwitchToAddDishesView, ExecuteSwitchToAddDishesView);
            DeleteDishesCommand = new RelayCommand<object>(CanExecuteDeleteDish, ExecuteDeleteDish);
            SelectedDishCommand = new RelayCommand<object>(CanExecuteSelectDish, ExecuteSelectDish);
            AddDishImageCommand = new RelayCommand(AddDishImageAsync);
            EditDishImageCommand = new RelayCommand(EditDishImageAsync);
            ViewIngredientsCommand = new RelayCommand(ViewIngredients);
            //ChangeDishInfoCommand = new RelayCommand<object>(CanExecuteChangeDishInfo, ExecuteChangeDishInfo);
        }

        #region define commands

        private bool CanExecuteSwitchToAddDishesView(object? parameter)
        {
            return SelectedDish != null;
        }

        private void ExecuteSwitchToAddDishesView(object? parameter)
        {
            //AddedDish = new Doanuong();
            EditView = Visibility.Collapsed;
            AddView = Visibility.Visible;
        }

        private void AddDishes(object? parameter)
        {
            try
            {
                // Validate input
                if (string.IsNullOrWhiteSpace(AddedDish.TenDoAnUong))
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng nhập tên món!");
                    return;
                }

                if (AddedDish.DonGia <= 0)
                {
                    System.Windows.Forms.MessageBox.Show("Giá món phải lớn hơn 0!");
                    return;
                }

                if (AddedDish.ThoiGianChuanBi <= 0)
                {
                    System.Windows.Forms.MessageBox.Show("Thời gian chuẩn bị phải lớn hơn 0!");
                    return;
                }

                if (string.IsNullOrWhiteSpace(SelectedDishType))
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng chọn loại món!");
                    return;
                }

                if (AddedDish.AnhDoAnUong == null || AddedDish.AnhDoAnUong.Length == 0)
                {
                    System.Windows.Forms.MessageBox.Show("Vui lòng chọn ảnh món ăn!");
                    return;
                }

                var newDish = new Doanuong
                {
                    TenDoAnUong = AddedDish.TenDoAnUong.Trim(),
                    DonGia = AddedDish.DonGia,
                    ThoiGianChuanBi = AddedDish.ThoiGianChuanBi,
                    Loai = SelectedDishType == "Thức uống",
                    AnhDoAnUong = AddedDish.AnhDoAnUong
                };

                using var context = new QlnhContext();
                context.Doanuongs.Add(newDish);
                context.SaveChangesAsync();

                LoadData();
               
                System.Windows.Forms.MessageBox.Show("Thêm món thành công!");
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show($"Lỗi khi thêm món: {ex.Message}\nChi tiết: {ex.InnerException?.Message}");
            }
        }

        private bool CanExecuteDeleteDish(object? parameter)
        {
            return SelectedDish != null;
        }

        private void ExecuteDeleteDish(object? parameter)
        {
            try
            {
                if (SelectedDish != null)
                {
                    var confirmResult = System.Windows.MessageBox.Show(
                        $"Bạn có chắc muốn xóa món {SelectedDish.TenDoAnUong} không",
                        "Xác nhận xóa",
                        MessageBoxButton.YesNo,
                        MessageBoxImage.Question
                        );
                    if (confirmResult == MessageBoxResult.Yes)
                    {
                        using var context = new QlnhContext();
                        var dishToRemove = context.Doanuongs.Find(SelectedDish.Id);

                        if (dishToRemove != null)
                        {
                            context.Doanuongs.Remove(dishToRemove);
                            context.SaveChangesAsync();
                            LoadData();
                            System.Windows.MessageBox.Show("Xóa thành công!", "Thông báo", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                        else
                        {
                            System.Windows.MessageBox.Show("Không tìm thấy món ăn để xóa.", "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Windows.MessageBox.Show($"Có lỗi xảy ra: {ex.Message}", "Lỗi", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private bool CanExecuteSelectDish(object? parameter)
        {
            return true;
        }

        private void ExecuteSelectDish(object? parameter)
        {
            if (SelectedDish != null)
            {
                EditView = Visibility.Visible;
                AddView = Visibility.Collapsed;
                OnPropertyChanged(nameof(SelectedDish));
            }
        }

        private void AddDishImageAsync(object? parameter)
        {
            var ofd = new OpenFileDialog
            {
                Filter = "All supported graphics|*.jpg;*.jpeg;*.png|" + "JPEG (*.jpg;*.jpeg)|*.jpg;*.jpeg|" + "Portable Network Graphic (*.png)|*.png",
                Title = "Thêm ảnh món ăn"
            };

            if (ofd.ShowDialog() == DialogResult.OK)
            {
                string filePath = ofd.FileName;
                try
                {
                    var converter = new ImageConverter();
                    AddedDish.AnhDoAnUong = converter.BitmapImageToByteArray(filePath);
                    AddedImage = converter.ByteArrayToBitmapImage(AddedDish.AnhDoAnUong);
                }
                catch (Exception ex)
                {
                    System.Windows.Forms.MessageBox.Show($"Lỗi khi thêm ảnh: {ex.Message}");
                }
            }
        }

        private void EditDishImageAsync(object? parameter)
        {
            var ofd = new OpenFileDialog
            {
                Filter = "All supported graphics|*.jpg;*.jpeg;*.png|JPEG (*.jpg;*.jpeg)|*.jpg;*.jpeg|Portable Network Graphic (*.png)|*.png",
                Title = "Đổi ảnh món ăn"
            };

            if (ofd.ShowDialog() == DialogResult.OK)
            {
                string filePath = ofd.FileName;
                try
                {
                    if (SelectedDish.AnhDoAnUong != null)
                    {
                        var converter = new ImageConverter();
                        SelectedDish.AnhDoAnUong = converter.BitmapImageToByteArray(filePath);
                        EditedImage = converter.ByteArrayToBitmapImage(SelectedDish.AnhDoAnUong);

                        using var context = new QlnhContext();
                        var dishToUpdate = context.Doanuongs.FirstOrDefault(d => d.MaDoAnUong == SelectedDish.MaDoAnUong);
                        if (dishToUpdate != null)
                        {
                            dishToUpdate.AnhDoAnUong = SelectedDish.AnhDoAnUong;
                        }
                        context.SaveChangesAsync();
                        LoadData();

                        System.Windows.Forms.MessageBox.Show("Cập nhật ảnh thành công!");
                    }
                }
                catch (Exception ex)
                {
                    System.Windows.Forms.MessageBox.Show($"Lỗi khi cập nhật ảnh: {ex.Message}");
                }
            }
        }

        private void ViewIngredients(object? paramter)
        {
            AddIngredientsView addIngredientsView = new AddIngredientsView
            {
                DataContext = new AddIngredientViewModel
                {
                    SelectedDish_Ingredient = SelectedDish,
                    AddedIngredients = new ObservableCollection<DishDetails>(),
                    DeletedIngredients = new ObservableCollection<DishDetails>(),
                    
                    IngredientOfDish = new ObservableCollection<DishDetails>
                    (
                        dbContext.Ctmonans
                        .Where(ctma => ctma.IddoAnUong == SelectedDish.Id)
                        .Select(ctma => new DishDetails
                        {
                            IdDoAnUong = SelectedDish.Id,
                            IdNguyenLieu = ctma.IdnguyenLieuNavigation.Id,
                            TenNguyenLieu = ctma.IdnguyenLieuNavigation.TenNguyenLieu,
                            SoLuongNguyenLieu = ctma.SoLuongNguyenLieu
                        })
                        .ToList()
                    )
                }
            };
            addIngredientsView.ShowDialog();
        }

        #endregion

        public void FoodMenu_Filter()
        {
            if (ListDishes == null || !ListDishes.Any()) return;
            var filteredList = ListDishes.AsEnumerable();
            if (!string.IsNullOrWhiteSpace(FoodMenuFilterText))
            {
                filteredList = filteredList.Where(b => b.TenDoAnUong.Contains(FoodMenuFilterText, StringComparison.OrdinalIgnoreCase));
            }
            DisplayListDishes = new ObservableCollection<Doanuong>(filteredList);
        }
    }
}