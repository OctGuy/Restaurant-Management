using System;
using System.Collections.Generic;

namespace RestaurantManagement.Models;

public partial class Chebien
{
    public int Id { get; set; }

    public string? MaCheBien { get; set; }

    public int IdhoaDon { get; set; }

    public int ThoiGianChuanBi { get; set; }

    public virtual Hoadon IdhoaDonNavigation { get; set; } = null!;
}
