using RestaurantManagement.Models;
using RestaurantManagement.ViewModels;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows.Input;
using System.Collections.Generic;

namespace RestaurantManagement.ViewModels
{
    public class KitchenViewModel : BaseViewModel
    {
        private readonly QlnhContext _context;

        // Danh sách các món đang chờ hoàn thành
        private ObservableCollection<KitchenDish> _ListOrder;
        public ObservableCollection<KitchenDish> ListOrder
        {
            get => _ListOrder;
            set { _ListOrder = value; OnPropertyChanged(nameof(ListOrder)); }
        }

        // Danh sách các món đã hoàn thành
        private ObservableCollection<KitchenDish>? _ListDone;
        public ObservableCollection<KitchenDish>? ListDone
        {
            get => _ListDone;
            set { _ListDone = value; OnPropertyChanged(nameof(ListDone)); }
        }

        private KitchenDish? _OrderSelected;
        public KitchenDish? OrderSelected
        {
            get => _OrderSelected;
            set { _OrderSelected = value; OnPropertyChanged(nameof(OrderSelected)); }
        }

        private KitchenDish? _DoneSelected;
        public KitchenDish? DoneSelected
        {
            get => _DoneSelected;
            set { _DoneSelected = value; OnPropertyChanged(nameof(DoneSelected)); }
        }

        public ICommand MarkAsDoneCommand { get; set; }
        public ICommand ServeDishCommand { get; set; }

        public KitchenViewModel()
        {
            _context = new QlnhContext();
            ListOrder = new ObservableCollection<KitchenDish>();
            ListDone = new ObservableCollection<KitchenDish>();

            LoadData();
            MarkAsDoneCommand = new RelayCommand<object>(CanExecuteMarkAsDone, ExecuteMarkAsDone);
            ServeDishCommand = new RelayCommand<object>(CanExecuteServeDish, ExecuteServeDish);
        }

        private void LoadData()
        {
            //Lấy danh sách món đang chế biến
            //var orders = (from cthd in _context.Cthds
            //              join hd in _context.Hoadons on cthd.IdhoaDon equals hd.Id
            //              join da in _context.Doanuongs on cthd.IddoAnUong equals da.Id
            //              join b in _context.Bans on hd.Idban equals b.Id
            //              join cb in _context.Chebiens on hd.Id equals cb.IdhoaDon
            //              where cb.IsDeleted == false
            //              select new KitchenDish
            //              {
            //                  TenDoAnUong = da.TenDoAnUong,
            //                  IDBan = b.Id,
            //                  SoLuong = cthd.SoLuong,
            //                  IdCheBien = cb.Id
            //              }).Distinct().ToList();

            //ListOrder = new ObservableCollection<KitchenDish>(orders);

            var orders = (from cthd in _context.Cthds
                          join hd in _context.Hoadons on cthd.IdhoaDon equals hd.Id
                          join da in _context.Doanuongs on cthd.IddoAnUong equals da.Id
                          join b in _context.Bans on hd.Idban equals b.Id
                          join cb in _context.Chebiens on hd.Id equals cb.IdhoaDon
                          where cb.IsDeleted == false
                          select new KitchenDish
                          {
                              TenDoAnUong = da.TenDoAnUong,
                              IDBan = b.Id,
                              SoLuong = cthd.SoLuong,
                              IdCheBien = cb.Id
                          })
                      .Distinct()
                      .ToList();


            var uniqueOrders = orders
                .GroupBy(x => new { x.TenDoAnUong, x.IDBan })
                .Select(g => g.First())
                .Distinct()
                .ToList();

            ListOrder = new ObservableCollection<KitchenDish>(uniqueOrders);
            orders = null;
            uniqueOrders = null;


            // Lấy danh sách món đã hoàn thành
            var doneDishes = (from cthd in _context.Cthds
                              join hd in _context.Hoadons on cthd.IdhoaDon equals hd.Id
                              join da in _context.Doanuongs on cthd.IddoAnUong equals da.Id
                              join b in _context.Bans on hd.Idban equals b.Id
                              join cb in _context.Chebiens on hd.Id equals cb.IdhoaDon into cheBienGroup
                              from cb in cheBienGroup.DefaultIfEmpty()
                              where cb == null && cthd.IsDeleted == false
                              select new KitchenDish
                              {
                                  TenDoAnUong = da.TenDoAnUong,
                                  SoLuong = cthd.SoLuong,
                                  IDBan = b.Id,
                                  IdCheBien = 0
                              }).ToList();

            ListDone = new ObservableCollection<KitchenDish>(doneDishes);
            doneDishes = null;
        }


        private void ExecuteMarkAsDone(object parameter)
        {
            if (OrderSelected == null) return;

            var cb_dish = _context.Chebiens.FirstOrDefault(cb => cb.Id == OrderSelected.IdCheBien);

            if (cb_dish != null)
            {
                cb_dish.IsDeleted = true;
                _context.SaveChanges();

                var dishToMove = OrderSelected;
                ListOrder.Remove(dishToMove);
                ListDone.Add(dishToMove);
            }
        }

        private void ExecuteServeDish(object parameter)
        {
            if (DoneSelected == null) return;

            var doAn = _context.Doanuongs.FirstOrDefault(da => da.TenDoAnUong == DoneSelected.TenDoAnUong);
            if (doAn != null)
            {
                var dish = _context.Cthds.FirstOrDefault(x =>
                    x.IddoAnUong == doAn.Id && x.SoLuong == DoneSelected.SoLuong);

                if (dish != null)
                {
                    var ingredients = (from danl in _context.Ctmonans
                                       join nl in _context.Nguyenlieus on danl.IdnguyenLieu equals nl.Id
                                       where danl.IddoAnUong == doAn.Id
                                       select new { danl.IdnguyenLieu, danl.SoLuongNguyenLieu }).ToList();

                    foreach (var ingredient in ingredients)
                    {
                        var khoItem = _context.Ctkhos.FirstOrDefault(k => k.IdnguyenLieu == ingredient.IdnguyenLieu);

                        if (khoItem != null)
                        {
                            khoItem.SoLuongTonDu -= ingredient.SoLuongNguyenLieu * DoneSelected.SoLuong;
                            if (khoItem.SoLuongTonDu < 0)
                            {
                                khoItem.SoLuongTonDu = 0;
                            }
                        }
                    }

                    dish.IsDeleted = true;
                    _context.SaveChanges();

                    ListDone.Remove(DoneSelected);
                }
            }
        }


        private bool CanExecuteMarkAsDone(object parameter)
        {
            return OrderSelected != null;
        }

        private bool CanExecuteServeDish(object parameter)
        {
            return DoneSelected != null;
        }
    }


    public class KitchenDish
    {
        public string? TenDoAnUong { get; set; }
        public int? SoLuong { get; set; }
        public int? IDBan { get; set; }
        public int? IdCheBien { get; set; }
    }
}