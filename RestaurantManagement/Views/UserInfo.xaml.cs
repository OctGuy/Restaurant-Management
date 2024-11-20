using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace RestaurantManagement.View
{
    /// <summary>
    /// Interaction logic for UserInfo.xaml
    /// </summary>
    public partial class UserInfo : Window
    {
        public UserInfo()
        {
            InitializeComponent();
        }

        private void ShowCurrentPassword_Checked(object sender, RoutedEventArgs e)
        {
            currentPassword_Displayed.Text = currentPassword.Password;
            currentPassword.Visibility = Visibility.Collapsed;
            currentPassword_Displayed.Visibility = Visibility.Visible;
        }

        private void ShowCurrentPassword_Unchecked(object sender, RoutedEventArgs e)
        {
            currentPassword.Password = currentPassword_Displayed.Text;
            currentPassword_Displayed.Visibility = Visibility.Collapsed;
            currentPassword.Visibility = Visibility.Visible;
        }

        private void ShowNewPassword_Checked(object sender, RoutedEventArgs e)
        {
            newPassword_Displayed.Text = newPassword.Password;
            newPassword.Visibility = Visibility.Collapsed;
            newPassword_Displayed.Visibility = Visibility.Visible;
        }

        private void ShowNewPassword_Unchecked(object sender, RoutedEventArgs e)
        {
            newPassword.Password = newPassword_Displayed.Text;
            newPassword_Displayed.Visibility = Visibility.Collapsed;
            newPassword.Visibility = Visibility.Visible;
        }
        private void ShowConfirmPassword_Checked(object sender, RoutedEventArgs e)
        {
            confirmPassword_Displayed.Text = confirmPassword.Password;
            confirmPassword.Visibility = Visibility.Collapsed;
            confirmPassword_Displayed.Visibility = Visibility.Visible;
        }

        private void ShowConfirmPassword_Unchecked(object sender, RoutedEventArgs e)
        {
            confirmPassword.Password = confirmPassword_Displayed.Text;
            confirmPassword_Displayed.Visibility = Visibility.Collapsed;
            confirmPassword.Visibility = Visibility.Visible;
        }
    }
}
