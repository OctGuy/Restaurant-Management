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
	[NgayVaoLam] datetime not null,
	[LoaiNhanVien] nvarchar(20) not null, -- Full-time or Part-time
	[LuongThang] decimal(10,2), -- danh cho Fulltime, co the null đối với NV Partime 
	[LuongTheoGio] decimal(10,2),-- danh cho part tume, có thể null đối với NV FUlltime
	[SoNgayLamViec] int,  -- part-time
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
	[GiaNguyenLieu] decimal(10,2) not null default 0 -- = NguyenLieu.DonGia * SoLuong
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
FOREIGN KEY ([IDNhanVien]) REFERENCES [NHANVIEN]([ID]); --- THÊM


-- Insert data into DOANUONG table
INSERT INTO [DOANUONG] ([TenDoAnUong], [AnhDoAnUong], [DonGia], [TinhTrang], [ThoiGianChuanBi], [Loai])
VALUES
(N'Phở bò', NULL, 30000, 1, 10, 0),
(N'Bún chả', NULL, 35000, 1, 15, 0),
(N'Cơm tấm', NULL, 40000, 1, 20, 0),
(N'Sinh tố dâu', NULL, 25000, 1, 5, 1),
(N'Cafe sữa', NULL, 20000, 1, 5, 1),
(N'Gỏi cuốn', NULL, 30000, 1, 10, 0),
(N'Hủ tiếu', NULL, 35000, 1, 15, 0),
(N'Nước ngọt', NULL, 10000, 1, 2, 1),
(N'Bánh mì', NULL, 20000, 1, 5, 0),
(N'Nước cam', NULL, 15000, 1, 3, 1);

-- Insert data into HOADON table
INSERT INTO [HOADON] ([IDBan], [IDNhanVien], [NgayHoaDon], [TongGia])
VALUES
(1, 1, '2023-12-01', 150000),
(2, 2, '2023-12-02', 200000),
(3, 3, '2023-12-03', 180000),
(4, 4, '2023-12-04', 220000),
(5, 5, '2023-12-05', 250000),
(6, 6, '2023-12-06', 300000),
(7, 7, '2023-12-07', 170000),
(8, 8, '2023-12-08', 190000),
(9, 9, '2023-12-09', 210000),
(10, 10, '2023-12-10', 230000);

-- Insert data into CTHD table
INSERT INTO [CTHD] ([IDHoaDon], [IDDoAnUong], [SoLuong])
VALUES
(1, 1, 2),
(2, 2, 1),
(3, 3, 3),
(4, 4, 2),
(5, 5, 1),
(6, 6, 2),
(7, 7, 1),
(8, 8, 3),
(9, 9, 2),
(10, 10, 1);

-- Insert data into NGUYENLIEU table
INSERT INTO [NGUYENLIEU] ([TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai])
VALUES
(N'Gạo', N'kg', 20000, 1, 0),
(N'Thịt bò', N'kg', 250000, 1, 0),
(N'Rau thơm', N'mớ', 5000, 1, 0),
(N'Trứng', N'quả', 3000, 1, 0),
(N'Nước mắm', N'lít', 20000, 1, 0),
(N'Cafe', N'kg', 100000, 1, 1),
(N'Sữa đặc', N'lít', 15000, 1, 1),
(N'Dâu tây', N'kg', 80000, 1, 1),
(N'Nước ngọt', N'chai', 10000, 1, 1),
(N'Nước cam', N'lít', 25000, 1, 1);

-- Insert data into CTMONAN using numbers for IDs and quantities
INSERT INTO [CTMONAN] ([IDDoAnUong], [IDNguyenLieu], [SoLuongNguyenLieu])
VALUES
-- Phở bò
(1, 1, 1), -- 1 kg Gạo cho Phở bò
(1, 2, 0.3), -- 0.3 kg Thịt bò cho Phở bò

-- Bún chả
(2, 1, 1), -- 1 kg Gạo cho Bún chả
(2, 2, 0.2), -- 0.2 kg Thịt bò cho Bún chả

-- Cơm tấm
(3, 1, 1), -- 1 kg Gạo cho Cơm tấm
(3, 2, 0.3); -- 0.3 kg Thịt bò cho Cơm tấm

INSERT INTO [KHO] (TenKho)
VALUES
(N'Kho nguyên liệu thô'),
(N'Kho nước uống')

Select * from NGUYENLIEU
SELECT * from KHO

select * from NGUYENLIEU
select * from NHAPKHO

INSERT INTO [NHAPKHO] ([NguonNhap], [NgayNhap], [GiaNhap], [SDTLienLac], [IDKho])
VALUES 
('Chợ gạo', GETDATE(), 100000, 123456, 1),
('Chợ bò', GETDATE(), 1250000, 123456, 1),
('Chợ rau', GETDATE(), 25000, 123456, 1),
('Chợ trứng', GETDATE(), 15000, 123456, 1),
('Chợ nước mắm', GETDATE(), 100000, 123456, 1),
('Chợ cafe', GETDATE(), 500000, 123456, 2),
('Chợ sữa đặc', GETDATE(), 75000, 123456, 2),
('Chợ dâu tây', GETDATE(), 400000, 123456, 2),
('Chợ nước ngọt', GETDATE(), 50000, 123456, 2),
('Chợ nước cam', GETDATE(), 125000, 123456, 2)

INSERT INTO [CTNHAPKHO] (IDNhapKho, IDNguyenLieu, SoLuongNguyenLieu, GiaNguyenLieu)
VALUES
(7, 1, 5, 10000),
(8, 2, 5, 1250000),
(9, 3, 5, 25000),
(10, 4, 5, 15000),
(11, 5, 5, 100000),
(12, 6, 5, 500000),
(13, 7, 5, 75000),
(14, 8, 5, 400000),
(15, 9, 5, 50000),
(16, 10, 5, 125000)

INSERT INTO [CTKHO] (IDKho, IDNguyenLieu, SoLuongTonDu)
VALUES
(1, 1, 5),
(1, 2, 5),
(1, 3, 5),
(1, 4, 5),
(1, 5, 5),
(2, 6, 5),
(2, 7, 5),
(2, 8, 5),
(2, 9, 5),
(2, 10, 5)

