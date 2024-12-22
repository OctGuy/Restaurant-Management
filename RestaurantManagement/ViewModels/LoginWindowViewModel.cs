using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using RestaurantManagement.Models;
using System.Windows;
using System.Text.RegularExpressions;
using RestaurantManagement.ViewModels;
using System.Data;

public class LoginWindowViewModel : INotifyPropertyChanged
{
    private string _username;
    private string _password;
    private string _errorMessage;
    private readonly QlnhContext _context;
    private bool _role;
    public string Username
    {
        get => _username;
        set
        {
            _username = value;
            OnPropertyChanged();
            (LoginCommand as RelayCommand)?.RaiseCanExecuteChanged();
        }
    }
    
    public string Password
    {
        get => _password;
        set
        {
            _password = value;
            OnPropertyChanged();
            (LoginCommand as RelayCommand)?.RaiseCanExecuteChanged();
        }
    }

    public string ErrorMessage
    {
        get => _errorMessage;
        set
        {
            _errorMessage = value;
            OnPropertyChanged();
        }
    }
    public bool Role
    {
        get => _role;
        set
        {
            _role = value;
            OnPropertyChanged();
        }
    }

    public ICommand LoginCommand { get; set; }

    public LoginWindowViewModel(QlnhContext context)
    {
        _context = context;

        Username = "";
        Password = "";
        LoginCommand = new RelayCommand(ExecuteLogin);
    }


    private void ExecuteLogin(object parameter)
    {
        if (!IsValidInput(Username) || !IsValidInput(Password))
        {
            ErrorMessage = "Tên đăng nhập và mật khẩu không bao gồm ký tự đặc biệt";
            OnPropertyChanged(nameof(ErrorMessage));
            return;
        }

        try
        {
            var user = _context.Taikhoans
                .FirstOrDefault(t => t.TenTaiKhoan == Username && t.MatKhau == Password);

            if (user != null)
            {
                Role = (user.PhanQuyen == 0);

                ErrorMessage = "";
                if (Role)
                {
                    MessageBox.Show("Đăng nhập thành công với quyền Admin!");
                }
                else
                {
                    MessageBox.Show("Đăng nhập thành công với quyền Nhân viên!");
                }
            }
            else
            {
                ErrorMessage = "Tên đăng nhập hoặc mật khẩu không đúng!";
            }
        }
        catch (Exception ex)
        {
            ErrorMessage = $"Đã xảy ra lỗi: {ex.Message}";
        }
    }

    private bool IsValidInput(string input)
    {
        var regex = new Regex("^[a-zA-Z0-9_-]+$");
        return regex.IsMatch(input);
    }

    public event PropertyChangedEventHandler PropertyChanged;

    protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

}