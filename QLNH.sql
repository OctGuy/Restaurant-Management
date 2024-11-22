CREATE DATABASE QLNH
GO

USE QLNH 
GO

CREATE TABLE [NHANVIEN]
(
	[ID] int identity(1,1) constraint[PK_NHANVIEN] primary key,
	[MaNhanVien] as ('NV' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[HoTen] nvarchar(50) not null,
	[SDT] nvarchar(20) not null,
	[DiaChi] nvarchar(50) not null,
	[NgaySinh] datetime not null,
	[CongViec] nvarchar(20),
	[Avatar] varbinary(max),
	[NgayVaoLam] datetime not null,
	[LoaiNhanVien] nvarchar(20) not null, -- Full-time or Part-time
	[LuongThang] decimal(10,2) not null default 0, -- danh cho Fulltime
	[LuongCoBan] decimal(10,2) not null default 0, -- part-time
	[SoNgayLamViec] int not null default 0 -- part-time
)

CREATE TABLE [TAIKHOAN]
(
	[ID] int identity(1,1) constraint[PK_TAIKHOAN] primary key,
	[MaTaiKhoan] as ('TK' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[TenTaiKhoan] nvarchar(20) unique not null,
	[MatKhau] nvarchar(100) not null,
	[PhanQuyen] int not null, -- 0 : admin, 1 : nhan vien
	[IDNhanVien] int not null -- FK
)

CREATE TABLE [BAN]
(
	[ID] int identity(1,1) constraint[PK_BAN] primary key,
	[MaBan] as ('B' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[SucChua] int not null default 0,
	[TrangThai] bit not null -- 0: Het cho, 1: trong
)

CREATE TABLE [DOANUONG]
(
	[ID] int identity(1,1) constraint[PK_DOANUONG] primary key,
	[MaDoAnUong] as ('DAU' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[TenDoAnUong] nvarchar(100) not null,
	[AnhDoAnUong] varbinary(max) not null,
	[DonGia] decimal(10,2) not null default 0,
	[TinhTrang] bit not null, -- 0: het, 1: con
	[ThoiGianChuanBi] int not null default 0,
	[Loai] bit not null -- 0: do an, 1: do uong
)

CREATE TABLE [HOADON]
(
	[ID] int identity(1,1) constraint[PK_HOADON] primary key,
	[MaHoaDon] as ('HD' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[IDBan] int not null, -- FK
	[IDNhanVien] int not null, -- FK
	[NgayHoaDon] datetime not null,
	[TongGia] decimal(10,2) not null default 0 -- sum(CTHD.GiaMon)
)

CREATE TABLE [CTHD]
(
	[IDHoaDon] int not null, -- FK
	[IDDoAnUong] int not null, -- FK
	constraint [PK_CTHD] primary key([IDHoaDon], [IDDoAnUong]),
	[SoLuong] int not null default 0,
	[GiaMon] decimal not null default 0 -- = DoAnUong.DonGia * SoLuong (ĐỀ XUẤT BỎ)
)

CREATE TABLE [NGUYENLIEU]
(
	[ID] int identity(1,1) constraint[PK_NGUYENLIEU] primary key,
	[MaNguyenLieu] as ('NL' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[TenNguyenLieu] nvarchar(50) not null,
	[DonVi] nvarchar(10) not null,
	[DonGia] decimal(10,2) not null default 0,
	[TinhTrang] bit not null, -- 0: het, 1: con
	[Loai] bit not null -- 0: nguyen lieu tho (rau, ga, hai san,...), 1: do uong
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
	[NgayNhap] datetime not null,
	[GiaNhap] decimal not null default 0, -- sum(CTNhapKho.GiaNL)
	[SDTLienLac] nvarchar(20) not null,
	[IDKho] int not null -- FK
)

CREATE TABLE [CTNHAPKHO]
(
	[IDNhapKho] int not null, -- FK
	[IDNguyenLieu] int not null, -- FK
	constraint [PK_CTNK] primary key([IDNhapKho], [IDNguyenLieu]),
	[SoLuongNguyenLieu] int not null default 0,
	[GiaNguyenLieu] decimal(10,2) not null default 0 -- = NguyenLieu.DonGia * SoLuong
)

CREATE TABLE [CTKHO]
(
	[IDKho] int not null, -- FK
	[IDNguyenLieu] int not null, -- FK
	constraint [PK_CTK] primary key ([IDKho], [IDNguyenLieu]),
	[SoLuongTonDu] int not null default 0
)

CREATE TABLE [CHEBIEN]
(
	[ID] int identity(1,1) constraint[PK_CHEBIEN] primary key,
	[MaCheBien] as ('CB' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[IDHoaDon] int not null, -- fk, ko biet nen tham chieu den bang HOADON hay CTHD
	[ThoiGianChuanBi] int not null default 0
)


-------------------------------THÊM---------------------------NGÀY 22/11/2024------------------
CREATE TABLE [CHAMCONG] -- THÊM
(
    [ID] INT IDENTITY(1,1) CONSTRAINT [PK_CHAMCONG] PRIMARY KEY, -- Khóa chính
    [MaChamCong] AS ('CC' + RIGHT('00000' + CAST([ID] AS VARCHAR(5)), 5)) PERSISTED, 
    [IDNhanVien] INT NOT NULL, -- FK tham chiếu đến nhân viên
    [NgayChamCong] DATE NOT NULL, -- Ngày chấm công
    [GioVao] TIME NOT NULL, -- Giờ vào
    [GioRa] TIME NOT NULL, -- Giờ ra
    [SoGioLam] AS DATEDIFF(MINUTE, [GioVao], [GioRa]) / 60.0 PERSISTED -- Số giờ làm việc, tính tự động
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


---------------------- THÊM ------------------------ NGÀY 22/11/2024---------------------------------
ALTER TABLE [CHAMCONG] ADD CONSTRAINT [FK_CHAMCONG_IDNhanVien] 
FOREIGN KEY ([IDNhanVien]) REFERENCES [NHANVIEN]([ID]); --- THÊM

ALTER TABLE [NHANVIEN] DROP CONSTRAINT DF__NHANVIEN__SoNgay__398D8EEE -- XÓA RÀNG BUỘC DEFAULT CHO SoNgayLamViec
ALTER TABLE [NHANVIEN] DROP COLUMN [SoNgayLamViec]; -- XÓA CỘT SoNgayLamViec (part-time)

ALTER TABLE [NHANVIEN] DROP CONSTRAINT DF__NHANVIEN__LuongC__38996AB5 -- XÓA RÀNG BUỘC DEFAULT CHO LuongCoBan
ALTER TABLE [NHANVIEN] DROP COLUMN [LuongCoBan]; -- XÓA CỘT LuongCoBan (part-time)
------------------------------------------------------------------------------------------------------------------