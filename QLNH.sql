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
	[SucChua] int not null default 0,
	[TrangThai] bit not null -- 0: Het cho, 1: trong
)

CREATE TABLE [DOANUONG]
(
	[ID] int identity(1,1) constraint[PK_DOANUONG] primary key,
	[MaDoAnUong] as ('DAU' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[TenDoAnUong] nvarchar(100) not null,
	[AnhDoAnUong] varbinary(max),
	[DonGia] decimal(10,2) not null default 0,
	[TinhTrang] bit not null, -- 0: het, 1: con
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
	[GiaMon] decimal not null default 0 -- = DoAnUong.DonGia * SoLuong (ĐỀ XUẤT BỎ)
	[IsDeleted] bit default 0
)

CREATE TABLE [NGUYENLIEU]
(
	[ID] int identity(1,1) constraint[PK_NGUYENLIEU] primary key,
	[MaNguyenLieu] as ('NL' + RIGHT('00000' + CAST([ID] as varchar(5)), 5)) persisted,
	[TenNguyenLieu] nvarchar(50) not null,
	[DonVi] nvarchar(10) not null,
	[DonGia] decimal(10,2) not null default 0,
	--[TonDu] int not null,
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
	[IDKho] int not null, -- FK
	[IsDeleted] bit default 0
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
	[IsDeleted] bit default 0
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

alter table [NGUYENLIEU] DROP COLUMN [TonDu]


Select * from [DOANUONG]
Select * from [CTMONAN]


select * from [NGUYENLIEU]
select * from [KHO]
select * from [NHAPKHO]
select * from [CTKHO]
select * from [CTNHAPKHO]

insert into CTKHO (IDKho, IDNguyenLieu, SoLuongTonDu)
values (1, 5, 200), (1, 6, 50), (1, 7, 20), (2, 8, 200), (2, 9, 250)
insert into CTMONAN(IDDoAnUong, IDNguyenLieu, SoLuongNguyenLieu)
values (1, 5, 4), (1, 6, 5), (1, 7, 10), (3, 5, 12), (3, 6, 28), (3, 7, 5)
INSERT INTO [NGUYENLIEU] ([TenNguyenLieu], [DonVi], [DonGia], [TinhTrang], [Loai])
VALUES
(N'Rau cải', N'kg', 15000, 1, 0), -- Nguyên liệu thô
(N'Thịt gà', N'kg', 70000, 1, 0), -- Nguyên liệu thô
(N'Tôm sú', N'kg', 120000, 1, 0), -- Nguyên liệu thô
(N'Nước ngọt Coca', N'chai', 10000, 1, 1), -- Đồ uống
(N'Nước suối Lavie', N'chai', 8000, 1, 1); -- Đồ uống

INSERT INTO NHAPKHO (NguonNhap, NgayNhap, SDTLienLac, IDKho)
VALUES 
('Công ty A', '2024-06-10', '0123456789', 1), -- Lần nhập 1
('Công ty B', '2024-06-11', '0987654321', 1), -- Lần nhập 2
('Công ty C', '2024-06-12', '0345678901', 1), -- Lần nhập 3
('Công ty D', '2024-06-13', '0765432198', 2), -- Lần nhập 4
('Công ty E', '2024-06-14', '0678901234', 2), -- Lần nhập 5
('Công ty F', '2024-06-15', '0789123456', 1); -- Lần nhập 6

INSERT INTO NHAPKHO (NguonNhap, NgayNhap, SDTLienLac, IDKho)
VALUES
('Công ty G', '2024-06-17', '0328256792', 2),
('Công ty H', '2024-06-18', '0986513630', 2)

INSERT INTO CTNHAPKHO (IDNhapKho, IDNguyenLieu, SoLuongNguyenLieu, GiaNguyenLieu)
VALUES 
(1, 2, 100, 20000.00 * 100), -- Lần nhập 1: Gạo (ID = 2)
(2, 3, 50, 150000.00 * 50), -- Lần nhập 2: Bò (ID = 3)
(3, 4, 200, 10000.00 * 200), -- Lần nhập 3: Nước ngọt (ID = 4)
(4, 5, 150, 15000.00 * 150), -- Lần nhập 4: Rau cải (ID = 5)
(5, 6, 30, 70000.00 * 30), -- Lần nhập 5: Thịt gà (ID = 6)
(6, 7, 20, 120000.00 * 20); -- Lần nhập 6: Tôm sú (ID = 7)
INSERT INTO CTNHAPKHO (IDNhapKho, IDNguyenLieu, SoLuongNguyenLieu, GiaNguyenLieu)
VALUES
(7, 8, 300, 10000.00 * 300),
(8, 9, 250, 8000.00 * 250)


UPDATE NHAPKHO
SET IDKho = 1
where id in (4, 5)

update NHAPKHO
set IDKho = 2
where id = 3

UPDATE CTKHO
SET SoLuongTonDu = CTNK.SoLuongNguyenLieu
FROM CTKHO CTK
JOIN CTNHAPKHO CTNK ON CTK.IDNguyenLieu = CTNK.IDNguyenLieu;

Update NGUYENLIEU
Set Loai = 0
Where ID = 2

Update NHAPKHO
Set IDKho = 1
Where ID = 1

Update CTNHAPKHO
SET IsDeleted = 0


delete from CTNHAPKHO where IDNhapKho = 10 and IDNguyenLieu = 10
delete from NHAPKHO where ID = 10
delete from NGUYENLIEU where ID = 10

ALTER TABLE [CTKHO]
ADD [IsDeleted] bit DEFAULT 0;

ALTER TABLE [CTNHAPKHO]
ADD [IsDeleted] bit DEFAULT 0;

ALTER TABLE [NGUYENLIEU]
ADD [IsDeleted] bit DEFAULT 0;

SELECT 
    req.session_id
    , req.total_elapsed_time AS duration_ms
    , req.cpu_time AS cpu_time_ms
    , req.total_elapsed_time - req.cpu_time AS wait_time
    , req.logical_reads
    , SUBSTRING (REPLACE (REPLACE (SUBSTRING (ST.text, (req.statement_start_offset/2) + 1, 
       ((CASE statement_end_offset
           WHEN -1
           THEN DATALENGTH(ST.text)  
           ELSE req.statement_end_offset
         END - req.statement_start_offset)/2) + 1) , CHAR(10), ' '), CHAR(13), ' '), 
      1, 512)  AS statement_text  
FROM sys.dm_exec_requests AS req
    CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS ST
ORDER BY total_elapsed_time DESC;