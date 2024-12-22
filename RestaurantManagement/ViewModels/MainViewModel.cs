//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text;
//using System.Threading.Tasks;
//using System.Windows.Input;

//namespace RestaurantManagement.ViewModels
//{
//    public class MainViewModel : BaseViewModel
//    {
//        public ICommand LogOutCommand { get; set; }

//        LogOut
//    }
//}

using Microsoft.EntityFrameworkCore.Metadata.Internal;
using RestaurantManagement.State.Navigator;
using RestaurantManagement.Views;
using System.Windows;
using System.Windows.Input;
using RestaurantManagement.ViewModels;

namespace RestaurantManagement.ViewModels
{
    public class MainViewModel : BaseViewModel
    {
        // Thuộc tính cho Navigator
        private Navigator navigator;
        public Navigator Navigator
        {
            get { return navigator; }
            set { navigator = value; OnPropertyChanged(); }
        }

        // Thuộc tính xác định hiển thị cho Admin hoặc Employee
        private Visibility _adminView = Visibility.Collapsed;
        public Visibility AdminView
        {
            get => _adminView;
            set
            {
                _adminView = value;
                OnPropertyChanged();
            }
        }

        private Visibility _employeeView = Visibility.Collapsed;
        public Visibility EmployeeView
        {
            get => _employeeView;
            set
            {
                _employeeView = value;
                OnPropertyChanged();
            }
        }

        // Command để tải Window
        public ICommand LoadWindowCommand { get; }

        // Command để đăng xuất
        public ICommand LogOutCommand { get; }

        public MainViewModel()
        {
            // Xử lý logic khi tải Window
            LoadWindowCommand = new RelayCommand<Window>((p) => true, (p) =>
            {
                if (p == null) return;

                p.Hide();
                LoginWindow loginWindow = new LoginWindow();
                var result = loginWindow.ShowDialog();

                if (result == true)
                {
                    var loginVM = loginWindow.DataContext as LoginWindowViewModel;
                    if (loginVM != null && loginVM.Role != -1)
                    {
                        Navigator = new Navigator(loginVM.Role);
                        p.Show(); // Show lại MainWindow
                    }
                    else
                    {
                        p.Close(); // Chỉ đóng khi không đăng nhập thành công
                    }
                }
                else
                {
                    p.Close(); // Đóng khi user hủy đăng nhập
                }
            });


            // Xử lý logic khi đăng xuất
            LogOutCommand = new RelayCommand<Window>((p) => true, (p) =>
            {
                if (p == null)
                {
                    return;
                }
                System.Windows.Forms.Application.Restart();
                p.Close();
            });
        }
    }
}
