CREATE DATABASE QLNH
GO

USE QLNH 
GO
set dateformat dmy
CREATE TABLE [NHANVIEN]
(
	[ID] int identity(1,1) constraint[PK_NHANVIEN] primary key,
	[MaNhanVien] as ('NV' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[HoTen] nvarchar(50) not null,
	[SDT] nvarchar(20) not null,
	[DiaChi] nvarchar(50) not null,
	[NgaySinh] datetime not null,
	[CongViec] nvarchar(20),
	[NgayVaoLam] datetime not null,
	[LoaiNhanVien] nvarchar(20) not null, -- Full-time or Part-time
	[LuongThang] decimal(10,2), -- danh cho Fulltime, co the null đối với NV Partime 
	[LuongTheoGio] decimal(10,2),-- danh cho part tume, có thể null đối với NV FUlltime
	[IsDeleted] bit default 0
)

CREATE TABLE [TAIKHOAN]
(
	[ID] int identity(1,1) constraint[PK_TAIKHOAN] primary key,
	[MaTaiKhoan] as ('TK' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[TenTaiKhoan] nvarchar(20) unique not null,
	[MatKhau] nvarchar(100) not null,
	[PhanQuyen] int not null, -- 0 : admin, 1 : nhan vien
	[IDNhanVien] int not null, -- FK
	[IsDeleted] bit default 0
)

CREATE TABLE [BAN]
(
	[ID] int identity(1,1) constraint[PK_BAN] primary key,
	[MaBan] as ('B' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[SucChua] int default 0,
	[TrangThai] bit -- 0: Het cho, 1: trong
)

CREATE TABLE [DOANUONG]
(
	[ID] int identity(1,1) constraint[PK_DOANUONG] primary key,
	[MaDoAnUong] as ('DAU' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[TenDoAnUong] nvarchar(100) not null,
	[AnhDoAnUong] nvarchar(max),
	[DonGia] decimal(10,2) not null default 0,
	[TinhTrang] bit default 1 not null, -- 0: het, 1: con
	[ThoiGianChuanBi] int not null default 0,
	[Loai] bit not null, -- 0: do an, 1: do uong
	[IsDeleted] bit default 0
)

CREATE TABLE [HOADON]
(
	[ID] int identity(1,1) constraint[PK_HOADON] primary key,
	[MaHoaDon] as ('HD' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[IDBan] int not null, -- FK
	[IDNhanVien] int not null, -- FK
	[NgayHoaDon] datetime not null,
	[TongGia] decimal(10,2) not null default 0, -- sum(CTHD.GiaMon)
	[IsDeleted] bit default 0
)

CREATE TABLE [CTHD]
(
	[IDHoaDon] int not null, -- FK
	[IDDoAnUong] int not null, -- FK
	constraint [PK_CTHD] primary key([IDHoaDon], [IDDoAnUong]),
	[SoLuong] int not null default 0,
	[GiaMon] decimal not null default 0, -- = DoAnUong.DonGia * SoLuong (ĐỀ XUẤT BỎ)
	[IsReady] bit default 0,
	[IsDeleted] bit default 0
)

CREATE TABLE [NGUYENLIEU]
(
	[ID] int identity(1,1) constraint[PK_NGUYENLIEU] primary key,
	[MaNguyenLieu] as ('NL' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[TenNguyenLieu] nvarchar(50) not null,
	[DonVi] nvarchar(10) not null,
	[DonGia] decimal(10,2) default 0,
	[TinhTrang] bit not null, -- 0: het, 1: con
	[Loai] bit not null, -- 0: nguyen lieu tho (rau, ga, hai san,...), 1: do uong
	[IsDeleted] bit default 0
	-- Đồ uống cũng đc xem như là nguyên liệu, có thể truyền qua bảng DOANUONG với Loai = 1 (do uong)
)

CREATE TABLE [CTMONAN] -- Chi co do an moi co chi tiet mon an
(
	[IDDoAnUong] int not null, -- FK
	[IDNguyenLieu] int not null, -- FK
	constraint [PK_CTMA] primary key([IDDoAnUong], [IDNguyenLieu]),
	[SoLuongNguyenLieu] int not null default 0
)

CREATE TABLE [KHO]
(
	[ID] int identity(1,1) constraint[PK_KHO] primary key,
	[MaKho] as ('K' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[TenKho] nvarchar(20) not null
)

CREATE TABLE [NHAPKHO]
(
	[ID] int identity(1,1) constraint[PK_NHAPKHO] primary key,
	[MaNhapKho] as ('NK' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[NguonNhap] nvarchar(50) not null,
	[NgayNhap] datetime,
	[GiaNhap] decimal default 0, -- sum(CTNhapKho.GiaNL)
	[SDTLienLac] nvarchar(20) not null,
	[IDKho] int not null, -- FK
)

CREATE TABLE [CTNHAPKHO]
(
	[IDNhapKho] int not null, -- FK
	[IDNguyenLieu] int not null, -- FK
	constraint [PK_CTNK] primary key([IDNhapKho], [IDNguyenLieu]),
	[SoLuongNguyenLieu] int not null default 0,
	[GiaNguyenLieu] decimal(18,2) not null default 0 -- = NguyenLieu.DonGia * SoLuong
)

CREATE TABLE [CTKHO]
(
	[IDKho] int not null, -- FK
	[IDNguyenLieu] int not null, -- FK
	constraint [PK_CTK] primary key ([IDKho], [IDNguyenLieu]),
	[SoLuongTonDu] int default 0,
	[IsDeleted] bit default 0
)

CREATE TABLE [CHEBIEN]
(
	[ID] int identity(1,1) constraint[PK_CHEBIEN] primary key,
	[MaCheBien] as ('CB' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[IDHoaDon] int not null, -- fk, ko biet nen tham chieu den bang HOADON hay CTHD
	[ThoiGianChuanBi] int not null default 0,
	[IsDeleted] bit default 0
)

CREATE TABLE [CHAMCONG] -- THÊM
(
    [ID] INT IDENTITY(1,1) CONSTRAINT [PK_CHAMCONG] PRIMARY KEY, -- Khóa chính
    [MaChamCong] AS ('CC' + RIGHT('00000' + CAST([ID] AS VARCHAR(5)), 5)) PERSISTED, 
    [IDNhanVien] INT NOT NULL, -- FK tham chiếu đến nhân viên
    [NgayChamCong] DATE NOT NULL, -- Ngày chấm công
    [GioVao] TIME NOT NULL, -- Giờ vào
    [GioRa] TIME NOT NULL, -- Giờ ra
    [SoGioLam] AS DATEDIFF(MINUTE, [GioVao], [GioRa]) / 60.0 PERSISTED, -- Số giờ làm việc, tính tự động
	[GhiChu] NVARCHAR(100),
	[IsDeleted] bit default 0
)
-----------------------------------------------------------------------------------------------

-- Foreign key
alter table [TAIKHOAN] add constraint [FK_TAIKHOAN_IDNhanVien]
foreign key ([IDNhanVien]) references [NHANVIEN]([ID]);

alter table [HOADON] add constraint [FK_HOADON_IDBan]
foreign key ([IDBan]) references [BAN]([ID]);

alter table [HOADON] add constraint [FK_HOADON_IDNhanVien]
foreign key ([IDNhanVien]) references [NHANVIEN]([ID]);

alter table [CTHD] add constraint [FK_CTHD_IDHoaDon]
foreign key ([IDHoaDon]) references [HOADON]([ID]);

alter table [CTHD] add constraint [FK_CTHD_IDDoAnUong]
foreign key ([IDDoAnUong]) references [DOANUONG]([ID]);

alter table [CTMONAN] add constraint [FK_CTMONAN_IDDoAnUong]
foreign key ([IDDoAnUong]) references [DOANUONG]([ID]);

alter table [CTMONAN] add constraint [FK_CTMONAN_IDNguyenLieu]
foreign key ([IDNguyenLieu]) references [NGUYENLIEU]([ID]);

alter table [NHAPKHO] add constraint [FK_NHAPKHO_IDKho]
foreign key ([IDKho]) references [KHO]([ID]);

alter table [CTNHAPKHO] add constraint [FK_CTNHAPKHO_IDNhapKho]
foreign key ([IDNhapKho]) references [NHAPKHO]([ID]);

alter table [CTNHAPKHO] add constraint [FK_CTNHAPKHO_IDNguyenLieu]
foreign key ([IDNguyenLieu]) references [NGUYENLIEU]([ID]);

alter table [CTKHO] add constraint [FK_CTKHO_IDKho]
foreign key ([IDKho]) references [KHO]([ID]);

alter table [CTKHO] add constraint [FK_CTKHO_IDNguyenLieu]
foreign key ([IDNguyenLieu]) references [NGUYENLIEU]([ID]);

alter table [CHEBIEN] add constraint [FK_CHEBIEN_IDHoaDon]
foreign key ([IDHoaDon]) references [HOADON]([ID]);

ALTER TABLE [CHAMCONG] ADD CONSTRAINT [FK_CHAMCONG_IDNhanVien] 
FOREIGN KEY ([IDNhanVien]) REFERENCES [NHANVIEN]([ID]);
----------------------------------------------------------------------------
--- Example data
SET IDENTITY_INSERT [dbo].[NHANVIEN] ON 

INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SDT], [DiaChi], [NgaySinh], [CongViec], [NgayVaoLam], [LoaiNhanVien], [LuongThang], [LuongTheoGio], [IsDeleted]) VALUES (1, N'Trần Đức Thịnh', N'0912345678', N'123 Đường A, Quận 1, TP.HCM', CAST(N'1990-05-15T00:00:00.000' AS DateTime), N'Quản lý', CAST(N'2022-01-15T00:00:00.000' AS DateTime), N'Full-time', CAST(15000000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0)
INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SDT], [DiaChi], [NgaySinh], [CongViec], [NgayVaoLam], [LoaiNhanVien], [LuongThang], [LuongTheoGio], [IsDeleted]) VALUES (2, N'Nguyễn Văn An', N'0912345678', N'123 Đường A, Quận 1, TP.HCM', CAST(N'1990-05-15T00:00:00.000' AS DateTime), N'Bếp trưởng', CAST(N'2022-01-15T00:00:00.000' AS DateTime), N'Full-time', CAST(15000000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0)
INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SDT], [DiaChi], [NgaySinh], [CongViec], [NgayVaoLam], [LoaiNhanVien], [LuongThang], [LuongTheoGio], [IsDeleted]) VALUES (3, N'Trần Thị Bích', N'0987654321', N'456 Đường B, Quận 2, TP.HCM', CAST(N'1995-08-20T00:00:00.000' AS DateTime), N'Phục vụ', CAST(N'2022-03-01T00:00:00.000' AS DateTime), N'Full-time', CAST(10000000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0)
INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SDT], [DiaChi], [NgaySinh], [CongViec], [NgayVaoLam], [LoaiNhanVien], [LuongThang], [LuongTheoGio], [IsDeleted]) VALUES (4, N'Lê Văn Cường', N'0901234567', N'789 Đường C, Quận 3, TP.HCM', CAST(N'1997-11-10T00:00:00.000' AS DateTime), N'Đầu bếp', CAST(N'2022-02-25T00:00:00.000' AS DateTime), N'Full-time', CAST(12000000.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0)
INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SDT], [DiaChi], [NgaySinh], [CongViec], [NgayVaoLam], [LoaiNhanVien], [LuongThang], [LuongTheoGio], [IsDeleted]) VALUES (5, N'Phạm Thị Dung', N'0978123456', N'321 Đường D, Quận 4, TP.HCM', CAST(N'1993-06-25T00:00:00.000' AS DateTime), N'Order', CAST(N'2023-06-01T00:00:00.000' AS DateTime), N'Part-time', CAST(0.00 AS Decimal(10, 2)), CAST(50000.00 AS Decimal(10, 2)), 0)
INSERT [dbo].[NHANVIEN] ([ID], [HoTen], [SDT], [DiaChi], [NgaySinh], [CongViec], [NgayVaoLam], [LoaiNhanVien], [LuongThang], [LuongTheoGio], [IsDeleted]) VALUES (6, N'Lê Bùi Quốc Huy', N'0978123456', N'321 Đường D, Quận 4, TP.HCM', CAST(N'1993-06-25T00:00:00.000' AS DateTime), N'Order', CAST(N'2023-06-01T00:00:00.000' AS DateTime), N'Part-time', CAST(0.00 AS Decimal(10, 2)), CAST(50000.00 AS Decimal(10, 2)), 0)
SET IDENTITY_INSERT [dbo].[NHANVIEN] OFF
GO
SET IDENTITY_INSERT [dbo].[TAIKHOAN] ON 

INSERT [dbo].[TAIKHOAN] ([ID], [TenTaiKhoan], [MatKhau], [PhanQuyen], [IDNhanVien], [IsDeleted]) VALUES (1, N'admin', N'admin123', 0, 1, 0)
INSERT [dbo].[TAIKHOAN] ([ID], [TenTaiKhoan], [MatKhau], [PhanQuyen], [IDNhanVien], [IsDeleted]) VALUES (2, N'staff1', N'staff1', 1, 2, 0)
INSERT [dbo].[TAIKHOAN] ([ID], [TenTaiKhoan], [MatKhau], [PhanQuyen], [IDNhanVien], [IsDeleted]) VALUES (3, N'staff2', N'staff2', 1, 3, 0)
INSERT [dbo].[TAIKHOAN] ([ID], [TenTaiKhoan], [MatKhau], [PhanQuyen], [IDNhanVien], [IsDeleted]) VALUES (4, N'staff3', N'staff3', 1, 4, 0)
INSERT [dbo].[TAIKHOAN] ([ID], [TenTaiKhoan], [MatKhau], [PhanQuyen], [IDNhanVien], [IsDeleted]) VALUES (5, N'staff4', N'staff4', 1, 5, 0)
INSERT [dbo].[TAIKHOAN] ([ID], [TenTaiKhoan], [MatKhau], [PhanQuyen], [IDNhanVien], [IsDeleted]) VALUES (6, N'staff5', N'staff5', 1, 6, 0)
SET IDENTITY_INSERT [dbo].[TAIKHOAN] OFF
GO
SET IDENTITY_INSERT [dbo].[BAN] ON 

INSERT [dbo].[BAN] ([ID], [SucChua], [TrangThai]) VALUES (1, 4, 0)
INSERT [dbo].[BAN] ([ID], [SucChua], [TrangThai]) VALUES (2, 2, 0)
INSERT [dbo].[BAN] ([ID], [SucChua], [TrangThai]) VALUES (3, 6, 0)
INSERT [dbo].[BAN] ([ID], [SucChua], [TrangThai]) VALUES (4, 4, 0)
INSERT [dbo].[BAN] ([ID], [SucChua], [TrangThai]) VALUES (5, 8, 0)
INSERT [dbo].[BAN] ([ID], [SucChua], [TrangThai]) VALUES (6, 5, 0)
INSERT [dbo].[BAN] ([ID], [SucChua], [TrangThai]) VALUES (7, 10, 0)
SET IDENTITY_INSERT [dbo].[BAN] OFF
GO
SET IDENTITY_INSERT [dbo].[HOADON] ON 

INSERT [dbo].[HOADON] ([ID], [IDBan], [IDNhanVien], [NgayHoaDon], [TongGia], [IsDeleted]) VALUES (1, 1, 2, CAST(N'2024-12-30T21:58:26.963' AS DateTime), CAST(150000.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[HOADON] ([ID], [IDBan], [IDNhanVien], [NgayHoaDon], [TongGia], [IsDeleted]) VALUES (2, 2, 2, CAST(N'2024-12-30T21:58:47.733' AS DateTime), CAST(426000.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[HOADON] ([ID], [IDBan], [IDNhanVien], [NgayHoaDon], [TongGia], [IsDeleted]) VALUES (3, 3, 2, CAST(N'2024-12-30T21:59:10.817' AS DateTime), CAST(573000.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[HOADON] ([ID], [IDBan], [IDNhanVien], [NgayHoaDon], [TongGia], [IsDeleted]) VALUES (4, 4, 2, CAST(N'2024-12-30T21:59:46.050' AS DateTime), CAST(5025000.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[HOADON] ([ID], [IDBan], [IDNhanVien], [NgayHoaDon], [TongGia], [IsDeleted]) VALUES (5, 6, 2, CAST(N'2024-12-30T22:00:24.790' AS DateTime), CAST(11740000.00 AS Decimal(10, 2)), 1)
INSERT [dbo].[HOADON] ([ID], [IDBan], [IDNhanVien], [NgayHoaDon], [TongGia], [IsDeleted]) VALUES (6, 7, 2, CAST(N'2024-12-30T22:01:38.247' AS DateTime), CAST(1933000.00 AS Decimal(10, 2)), 1)
SET IDENTITY_INSERT [dbo].[HOADON] OFF
GO
SET IDENTITY_INSERT [dbo].[CHAMCONG] ON 

INSERT [dbo].[CHAMCONG] ([ID], [IDNhanVien], [NgayChamCong], [GioVao], [GioRa], [GhiChu], [IsDeleted]) VALUES (1, 5, CAST(N'2024-12-30' AS Date), CAST(N'07:00:00' AS Time), CAST(N'16:00:00' AS Time), N'', 0)
INSERT [dbo].[CHAMCONG] ([ID], [IDNhanVien], [NgayChamCong], [GioVao], [GioRa], [GhiChu], [IsDeleted]) VALUES (2, 6, CAST(N'2024-12-30' AS Date), CAST(N'08:00:00' AS Time), CAST(N'17:00:00' AS Time), N'', 0)
SET IDENTITY_INSERT [dbo].[CHAMCONG] OFF
GO
SET IDENTITY_INSERT [dbo].[DOANUONG] ON 

INSERT [dbo].[DOANUONG] ([ID], [TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai], [IsDeleted]) VALUES (1, N'Bò bít tết', N'https://img.pikbest.com/origin/10/02/88/50KpIkbEsTNtu.jpg!w700wp', CAST(100000.00 AS Decimal(10, 2)), 1, 15, 0, 0)
INSERT [dbo].[DOANUONG] ([ID], [TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai], [IsDeleted]) VALUES (2, N'Nước suối', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQBWJUTHzT_bW7xCKeBpL0ISrl64figf015Lw&s', CAST(10000.00 AS Decimal(10, 2)), 1, 1, 1, 0)
INSERT [dbo].[DOANUONG] ([ID], [TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai], [IsDeleted]) VALUES (3, N'Bún chả', N'https://bizweb.dktcdn.net/100/442/328/files/bun-cha-mon-dac-san-binh-di-cua-nguoi-ha-noi-1.jpg?v=1638938776859', CAST(50000.00 AS Decimal(10, 2)), 1, 10, 0, 0)
INSERT [dbo].[DOANUONG] ([ID], [TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai], [IsDeleted]) VALUES (4, N'Bia Heineken', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRzdKDqWdMwnSVRPTUj0iPZ07FAwpTv0rwTFw&s', CAST(25000.00 AS Decimal(10, 2)), 1, 1, 1, 0)
INSERT [dbo].[DOANUONG] ([ID], [TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai], [IsDeleted]) VALUES (5, N'Coca Cola', N'https://product.hstatic.net/1000141988/product/nuoc_ngot_cocacola_vi_nguyen_ban_320_ml_5545f89b5d434c548a8bff6118a3ed49.jpg', CAST(18000.00 AS Decimal(10, 2)), 1, 1, 1, 0)
INSERT [dbo].[DOANUONG] ([ID], [TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai], [IsDeleted]) VALUES (6, N'Rượu Soju', N'https://ruoungoaigiasi.vn/image/catalog/san-pham/soju/jinro/ruou-soju-jinro-chamisul-classic.jpg', CAST(80000.00 AS Decimal(10, 2)), 1, 1, 0, 0)
INSERT [dbo].[DOANUONG] ([ID], [TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai], [IsDeleted]) VALUES (7, N'Strongbow', N'https://famima.vn/wp-content/uploads/2023/11/Strongbow-dau-den-lon-330ml-01-2.jpg', CAST(30000.00 AS Decimal(10, 2)), 1, 1, 1, 0)
INSERT [dbo].[DOANUONG] ([ID], [TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai], [IsDeleted]) VALUES (8, N'Sting', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGPWcibM7QXRw4-B41fPyLTu4YSzc-4RCkEQ&s', CAST(18000.00 AS Decimal(10, 2)), 1, 1, 1, 0)
INSERT [dbo].[DOANUONG] ([ID], [TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai], [IsDeleted]) VALUES (9, N'Lẩu bò', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSL8HwB0StM7SIyrgtEWQlOhH0Us04r4fwVMw&s', CAST(300000.00 AS Decimal(10, 2)), 1, 20, 0, 0)
SET IDENTITY_INSERT [dbo].[DOANUONG] OFF
GO
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (1, 1, 1, CAST(100000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (1, 3, 1, CAST(50000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (2, 2, 1, CAST(10000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (2, 5, 1, CAST(18000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (2, 6, 1, CAST(80000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (2, 8, 1, CAST(18000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (2, 9, 1, CAST(300000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (3, 1, 1, CAST(100000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (3, 3, 1, CAST(50000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (3, 4, 1, CAST(25000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (3, 5, 1, CAST(18000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (3, 6, 1, CAST(80000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (3, 9, 1, CAST(300000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (4, 1, 12, CAST(100000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (4, 4, 1, CAST(25000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (4, 6, 10, CAST(80000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (4, 9, 10, CAST(300000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (5, 1, 30, CAST(100000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (5, 4, 4, CAST(25000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (5, 6, 9, CAST(80000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (5, 7, 4, CAST(30000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (5, 9, 26, CAST(300000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (6, 2, 10, CAST(10000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (6, 4, 7, CAST(25000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (6, 5, 15, CAST(18000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (6, 6, 10, CAST(80000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (6, 7, 13, CAST(30000 AS Decimal(18, 0)), 1, 1)
INSERT [dbo].[CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong], [GiaMon], [IsReady], [IsDeleted]) VALUES (6, 8, 11, CAST(18000 AS Decimal(18, 0)), 1, 1)
GO
SET IDENTITY_INSERT [dbo].[NGUYENLIEU] ON 

INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (1, N'Salad', N'bó', CAST(4000.00 AS Decimal(10, 2)), 1, 0, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (2, N'Bánh mì', N'cái', CAST(1500.00 AS Decimal(10, 2)), 1, 0, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (3, N'Thịt bò', N'lạng', CAST(23000.00 AS Decimal(10, 2)), 1, 0, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (4, N'Thịt heo', N'lạng', CAST(13000.00 AS Decimal(10, 2)), 1, 0, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (5, N'Bơ thực vật', N'kg', CAST(1000.00 AS Decimal(10, 2)), 1, 0, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (6, N'Rau muống', N'bó', CAST(3000.00 AS Decimal(10, 2)), 1, 0, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (7, N'Bún', N'kg', CAST(1000.00 AS Decimal(10, 2)), 1, 0, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (8, N'Sting', N'lon', CAST(5000.00 AS Decimal(10, 2)), 1, 1, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (9, N'Bia Heineken', N'lon', CAST(10000.00 AS Decimal(10, 2)), 1, 1, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (10, N'Coca Cola', N'lon', CAST(6000.00 AS Decimal(10, 2)), 1, 1, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (11, N'Strongbow', N'lon', CAST(6000.00 AS Decimal(10, 2)), 1, 1, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (12, N'Nước suối', N'chai', CAST(1000.00 AS Decimal(10, 2)), 1, 1, 0)
INSERT [dbo].[NGUYENLIEU] ([ID], [TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai], [IsDeleted]) VALUES (13, N'Rượu Soju', N'chai', CAST(50000.00 AS Decimal(10, 2)), 1, 1, 0)
SET IDENTITY_INSERT [dbo].[NGUYENLIEU] OFF
GO
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (1, 1, 3)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (1, 2, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (1, 3, 2)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (1, 5, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (2, 12, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (3, 1, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (3, 4, 6)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (3, 6, 4)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (3, 7, 3)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (4, 9, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (5, 10, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (6, 13, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (7, 11, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (8, 8, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (9, 1, 1)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (9, 2, 2)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (9, 3, 3)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (9, 4, 4)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (9, 5, 5)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (9, 6, 6)
INSERT [dbo].[CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu]) VALUES (9, 7, 10)
GO
SET IDENTITY_INSERT [dbo].[CHEBIEN] ON 

INSERT [dbo].[CHEBIEN] ([ID], [IDHoaDon], [ThoiGianChuanBi], [IsDeleted]) VALUES (1, 1, 0, 0)
INSERT [dbo].[CHEBIEN] ([ID], [IDHoaDon], [ThoiGianChuanBi], [IsDeleted]) VALUES (2, 2, 0, 0)
INSERT [dbo].[CHEBIEN] ([ID], [IDHoaDon], [ThoiGianChuanBi], [IsDeleted]) VALUES (3, 3, 0, 0)
INSERT [dbo].[CHEBIEN] ([ID], [IDHoaDon], [ThoiGianChuanBi], [IsDeleted]) VALUES (4, 4, 0, 0)
INSERT [dbo].[CHEBIEN] ([ID], [IDHoaDon], [ThoiGianChuanBi], [IsDeleted]) VALUES (5, 5, 0, 0)
INSERT [dbo].[CHEBIEN] ([ID], [IDHoaDon], [ThoiGianChuanBi], [IsDeleted]) VALUES (6, 6, 0, 0)
SET IDENTITY_INSERT [dbo].[CHEBIEN] OFF
GO
SET IDENTITY_INSERT [dbo].[KHO] ON 

INSERT [dbo].[KHO] ([ID], [TenKho]) VALUES (1, N'Kho nguyên liệu thô')
INSERT [dbo].[KHO] ([ID], [TenKho]) VALUES (2, N'Kho nước uống')
SET IDENTITY_INSERT [dbo].[KHO] OFF
GO
SET IDENTITY_INSERT [dbo].[NHAPKHO] ON 

INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (1, N'Chợ rau', CAST(N'2024-12-30T00:00:00.000' AS DateTime), CAST(3000000 AS Decimal(18, 0)), N'0123456789', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (2, N'Chợ rau 1', CAST(N'2024-12-31T00:00:00.000' AS DateTime), CAST(5600000 AS Decimal(18, 0)), N'0123456788', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (3, N'Tiệm bánh mì', CAST(N'2024-12-30T00:00:00.000' AS DateTime), CAST(200000 AS Decimal(18, 0)), N'0123456788', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (4, N'Tiệm bánh mì', CAST(N'2024-12-31T00:00:00.000' AS DateTime), CAST(75000 AS Decimal(18, 0)), N'0123456788', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (5, N'Chợ thịt ', CAST(N'2024-12-30T00:00:00.000' AS DateTime), CAST(25000000 AS Decimal(18, 0)), N'0123456788', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (6, N'Chợ thịt 1', CAST(N'2024-12-31T00:00:00.000' AS DateTime), CAST(4600000 AS Decimal(18, 0)), N'0123456788', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (7, N'Chợ thịt ', CAST(N'2024-12-30T00:00:00.000' AS DateTime), CAST(16000000 AS Decimal(18, 0)), N'0123456788', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (8, N'Chợ thịt ', CAST(N'2025-01-01T00:00:00.000' AS DateTime), CAST(26000000 AS Decimal(18, 0)), N'0123456788', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (9, N'Chợ bơ', CAST(N'2024-11-30T00:00:00.000' AS DateTime), CAST(1000000 AS Decimal(18, 0)), N'123456', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (10, N'Chợ rau', CAST(N'2024-11-27T00:00:00.000' AS DateTime), CAST(200000 AS Decimal(18, 0)), N'123456', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (11, N'Chợ rau', CAST(N'2024-12-01T00:00:00.000' AS DateTime), CAST(600000 AS Decimal(18, 0)), N'123456', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (12, N'Lò bún', CAST(N'2024-12-01T00:00:00.000' AS DateTime), CAST(2000000 AS Decimal(18, 0)), N'123456', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (13, N'Lò bún 1', CAST(N'2024-12-02T00:00:00.000' AS DateTime), CAST(1500000 AS Decimal(18, 0)), N'123456', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (14, N'Tạp hóa', CAST(N'2024-12-02T00:00:00.000' AS DateTime), CAST(50000000 AS Decimal(18, 0)), N'123456', 2)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (15, N'Tạp hóa', CAST(N'2024-12-02T00:00:00.000' AS DateTime), CAST(100000000 AS Decimal(18, 0)), N'123456', 2)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (16, N'Tạp hóa', CAST(N'2024-12-02T00:00:00.000' AS DateTime), CAST(60000000 AS Decimal(18, 0)), N'123456', 2)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (17, N'Tạp hóa', CAST(N'2024-12-02T00:00:00.000' AS DateTime), CAST(60000000 AS Decimal(18, 0)), N'123456', 2)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (18, N'Tạp hóa', CAST(N'2024-12-02T00:00:00.000' AS DateTime), CAST(10000000 AS Decimal(18, 0)), N'123456', 2)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (19, N'Tạp hóa', CAST(N'2024-12-02T00:00:00.000' AS DateTime), CAST(50000000 AS Decimal(18, 0)), N'123456', 2)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (20, N'Chọ bơ', CAST(N'2024-12-30T00:00:00.000' AS DateTime), CAST(10000000 AS Decimal(18, 0)), N'123', 1)
INSERT [dbo].[NHAPKHO] ([ID], [NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho]) VALUES (21, N'Chọ bún', CAST(N'2024-12-30T00:00:00.000' AS DateTime), CAST(10000000 AS Decimal(18, 0)), N'123', 1)
SET IDENTITY_INSERT [dbo].[NHAPKHO] OFF
GO
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (1, 1, 1000, CAST(3000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (2, 1, 1400, CAST(5600000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (3, 2, 100, CAST(200000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (4, 2, 50, CAST(75000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (5, 3, 1000, CAST(25000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (6, 3, 200, CAST(4600000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (7, 4, 1000, CAST(16000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (8, 4, 2000, CAST(26000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (9, 5, 100, CAST(1000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (10, 6, 100, CAST(200000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (11, 6, 200, CAST(600000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (12, 7, 200, CAST(2000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (13, 7, 100, CAST(1500000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (14, 8, 10000, CAST(50000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (15, 9, 10000, CAST(100000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (16, 10, 10000, CAST(60000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (17, 11, 10000, CAST(60000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (18, 12, 10000, CAST(10000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (19, 13, 1000, CAST(50000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (20, 5, 10000, CAST(10000000.00 AS Decimal(18, 2)))
INSERT [dbo].[CTNHAPKHO] ([IDNhapKho], [IDNguyenLieu], [SoLuongNguyenLieu], [GiaNguyenLieu]) VALUES (21, 7, 10000, CAST(10000000.00 AS Decimal(18, 2)))
GO
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (1, 1, 2228, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (1, 2, 30, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (1, 3, 998, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (1, 4, 2836, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (1, 5, 10000, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (1, 6, 64, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (1, 7, 10000, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (2, 8, 9988, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (2, 9, 9987, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (2, 10, 9983, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (2, 11, 9983, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (2, 12, 9989, 0)
INSERT [dbo].[CTKHO] ([IDKho], [IDNguyenLieu], [SoLuongTonDu], [IsDeleted]) VALUES (2, 13, 969, 0)
GO