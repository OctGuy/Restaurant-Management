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
            public int Id { get; set; }
            public string? ingredientName { get; set; }
            public DateTime supplyDate { get; set; }
            public string? unit { get; set; }
            public decimal unitPrice { get; set; }
            public int quantity { get; set; }
            public bool type { get; set; } // 0: raw, 1: drink
            public string? supplySource { get; set; }
            public string? phoneNumber { get; set; }
            public int remainQuantity { get; set; }
        }

        public ICommand ResetFilterCommand { get; set; }

        private ObservableCollection<Ingredient> rawIngrdients;
        public ObservableCollection<Ingredient> RawIngredients
        {
            get => rawIngrdients;
            set
            {
                rawIngrdients = value;
                OnPropertyChanged();
                //ApplyFilter();
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

        private ObservableCollection<Ingredient> drinkIngrdients;
        public ObservableCollection<Ingredient> DrinkIngredients
        {
            get => drinkIngrdients;
            set
            {
                drinkIngrdients = value;
                OnPropertyChanged();
                //ApplyFilter();
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
                ApplyFilter();
            }
        }

        private int selectedDay;
        private int selectedMonth;
        private int selectedYear;

        public int SelectedDay { get; set; }
        public int SelectedMonth
        {
            get => selectedMonth;
            set
            {
                selectedMonth = value;
                UpdateDays();
                ApplyFilter();
            }
        }

        public int SelectedYear
        {
            get => selectedYear;
            set
            {
                selectedYear = value;
                UpdateDays();
                ApplyFilter();
            }
        }

        public List<int> Years { get; }
        public List<int> Months { get; }
        public ObservableCollection<int> Days { get; }

        public StorageViewModel()
        {
            dbContext = new QlnhContext();

            RawIngredients = new ObservableCollection<Ingredient>
            (
                dbContext.Nhapkhos
                .Where(nk => nk.IsDeleted == false && nk.Idkho == 1)
                .SelectMany(nk => nk.Ctnhapkhos, (nk, ctnk) => new { nk, ctnk })
                .Select(result => new Ingredient
                {
                    Id = result.nk.Id, // Id của NHAPKHO
                    ingredientName = result.ctnk.IdnguyenLieuNavigation.TenNguyenLieu,
                    supplyDate = result.nk.NgayNhap,
                    unit = result.ctnk.IdnguyenLieuNavigation.DonVi,
                    unitPrice = result.ctnk.IdnguyenLieuNavigation.DonGia,
                    quantity = result.ctnk.SoLuongNguyenLieu,
                    type = false,
                    supplySource = result.nk.NguonNhap,
                    phoneNumber = result.nk.SdtlienLac,
                    remainQuantity = dbContext.Ctkhos.Where(ctk => ctk.Idkho == result.nk.Idkho && ctk.IdnguyenLieu == result.ctnk.IdnguyenLieu)
                                                     .Select(ctk => ctk.SoLuongTonDu).FirstOrDefault()
                })
                .ToList()
            );

            DisplayRawIngredients = new ObservableCollection<Ingredient>(RawIngredients);

            DrinkIngredients = new ObservableCollection<Ingredient>
            (
                dbContext.Nhapkhos
                .Where(nk => nk.IsDeleted == false && nk.Idkho == 2)
                .SelectMany(nk => nk.Ctnhapkhos, (nk, ctnk) => new { nk, ctnk })
                .Select(result => new Ingredient
                {
                    Id = result.nk.Id, // Id của NHAPKHO
                    ingredientName = result.ctnk.IdnguyenLieuNavigation.TenNguyenLieu,
                    supplyDate = result.nk.NgayNhap,
                    unit = result.ctnk.IdnguyenLieuNavigation.DonVi,
                    unitPrice = result.ctnk.IdnguyenLieuNavigation.DonGia,
                    quantity = result.ctnk.SoLuongNguyenLieu,
                    type = true,
                    supplySource = result.nk.NguonNhap,
                    phoneNumber = result.nk.SdtlienLac,
                    remainQuantity = dbContext.Ctkhos.Where(ctk => ctk.Idkho == result.nk.Idkho && ctk.IdnguyenLieu == result.ctnk.IdnguyenLieu)
                                                     .Select(ctk => ctk.SoLuongTonDu).FirstOrDefault()
                })
                .ToList()
            );

            DisplayDrinkIngredients = new ObservableCollection<Ingredient>(DrinkIngredients);

            Years = Enumerable.Range(2000, DateTime.Now.Year - 2000 + 1).ToList();
            Months = Enumerable.Range(1, 12).ToList();
            Days = new ObservableCollection<int>();

            ResetFilterCommand = new RelayCommand(ResetFilter);
        }

        private void UpdateDays()
        {
            Days.Clear();
            if (SelectedYear > 0 && SelectedMonth > 0)
            {
                int daysInMonth = DateTime.DaysInMonth(SelectedYear, SelectedMonth);
                for (int i = 1; i <= daysInMonth; i++)
                    Days.Add(i);
            }
        }

        private void ApplyFilter()
        {
            DisplayRawIngredients.Clear();
            DisplayDrinkIngredients.Clear();

            var queryRaw = RawIngredients.AsEnumerable();
            var queryDrink = DrinkIngredients.AsEnumerable();

            if (!string.IsNullOrWhiteSpace(IngredientNameFilter))
            {
                queryRaw = queryRaw.Where(q => q.ingredientName.IndexOf(ingredientNameFilter, StringComparison.OrdinalIgnoreCase) >= 0);
                queryDrink = queryDrink.Where(q => q.ingredientName.IndexOf(ingredientNameFilter, StringComparison.OrdinalIgnoreCase) >= 0);
            }

            if (SelectedYear > 0)
            {
                queryRaw = queryRaw.Where(m => m.supplyDate.Year ==  SelectedYear);
                queryDrink = queryDrink.Where(m => m.supplyDate.Year == SelectedYear);
            }

            if (SelectedMonth > 0)
            {
                queryRaw = queryRaw.Where(m => m.supplyDate.Month == SelectedMonth);
                queryDrink = queryDrink.Where(m => m.supplyDate.Month == SelectedMonth);
            }

            if (SelectedDay > 0)
            {
                queryRaw = queryRaw.Where(m => m.supplyDate.Day == SelectedDay);
                queryDrink = queryDrink.Where(m => m.supplyDate.Day == SelectedDay);
            }

            foreach(var item in queryRaw)
            {
                DisplayRawIngredients.Add(item);
            }

            foreach(var item in queryDrink)
            {
                DisplayDrinkIngredients.Add(item);
            }
        }

        private void ResetFilter(object? parameter)
        {
            IngredientNameFilter = string.Empty;
            SelectedYear = 0;
            SelectedMonth = 0;
            SelectedDay = 0;
            DisplayRawIngredients = new ObservableCollection<Ingredient>(RawIngredients);
            DisplayDrinkIngredients = new ObservableCollection<Ingredient>(DrinkIngredients);
        }
    }
}
