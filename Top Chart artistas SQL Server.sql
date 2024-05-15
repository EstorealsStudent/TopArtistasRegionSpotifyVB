Use master
go
IF EXISTS (SELECT name FROM master.sys.databases WHERE name = N'TopArtistasRegion')
Drop DATABASE TopArtistasRegion
GO

CREATE DATABASE TopArtistasRegion
GO
USE TopArtistasRegion
GO


CREATE TABLE Artistas (
  Nombre NVARCHAR(255) ,
    Pais NVARCHAR(255),
) ;

--BULK Para insertar en la base de datos desde el archivo
BULK INSERT Artistas
FROM 'C:\Users\estor\OneDrive\Escritorio\TopartistasRegion\Top_Charts_Artists_Country.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
	FIRSTROW = 2,
    CODEPAGE = '65001' -- 65001 es el código de página para UTF-8
)
GO
CREATE TABLE Usuario
(
 Id INT IDENTITY(1,1) PRIMARY KEY,
 Nombre VARCHAR(50) NOT NULL,
 username VARCHAR(50) NOT NULL,
 Password VARCHAR(50) NOT NULL,
 Estatus BIT DEFAULT 1
)
GO

CREATE TABLE PAIS (
    Id INT  IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50),
	IdUsuarioCrea INT,
	FechaCrea DATETIME DEFAULT GETDATE(),
	IdUsuarioModifica INT NULL,
	FechaModifica DATETIME DEFAULT NULL,
	Estatus BIT DEFAULT 1

CONSTRAINT FK_PaisuarioCrea FOREIGN KEY  (IdUsuarioCrea) REFERENCES Usuario(Id),
CONSTRAINT FK_PaisUsuarioModifica FOREIGN KEY  (IdUsuarioModifica) REFERENCES Usuario(Id)
);
GO
CREATE TABLE ARTISTA (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50),
    IdPais INT,
	IdUsuarioCrea INT,
	FechaCrea DATETIME DEFAULT GETDATE(),
	IdUsuarioModifica INT NULL,
	FechaModifica DATETIME DEFAULT NULL,
	Estatus BIT DEFAULT 1
	CONSTRAINT FK_ArtistaPais FOREIGN KEY (IdPais) REFERENCES PAIS(Id),
	CONSTRAINT FK_ArtistauarioCrea FOREIGN KEY  (IdUsuarioCrea) REFERENCES Usuario(Id),
	CONSTRAINT FK_ArtistaUsuarioModifica FOREIGN KEY  (IdUsuarioModifica) REFERENCES Usuario(Id)
);
GO
INSERT INTO Usuario(Nombre,username,Password)
VALUES('Admin','Admin', CONVERT(NVARCHAR(50),HashBYTES('SHA1','Admin'),2))
GO

--Poblar las 2 tablas
INSERT INTO PAIS(Nombre,IdUsuarioCrea)
SELECT DISTINCT Pais,1 AS 'ID USUARIOCREA' FROM Artistas
GO
--delete from PAIS
--DBCC CHECKIDENT ('PAIS', RESEED, 1);  --- Esto hace el reinicio de los numero sde los identity

INSERT INTO ARTISTA (Nombre, IdPais,IdUsuarioCrea)
SELECT A.Nombre, P.Id,1 AS 'ID USUARIOCREA'
FROM Artistas A
INNER JOIN PAIS P ON A.Pais = P.Nombre
GO
--INDICES
CREATE INDEX IX_Usuario ON Usuario(id)
GO
CREATE INDEX IX_Pais ON PAIS(id)
GO
CREATE INDEX IX_Artista ON ARTISTA(id)
GO


CREATE VIEW VW_Top_Artistas AS
SELECT ARTISTA.Id AS [Top Artist], ARTISTA.Nombre, PAIS.Nombre AS Pais, Artista.Estatus
FROM ARTISTA
JOIN PAIS ON PAIS.Id = ARTISTA.IdPais;
GO


GO
CREATE PROCEDURE SP_VerificarCredenciales
@Usuario VARCHAR(50),
@Contraseña VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Nombre, Username 
    FROM Usuario 
    WHERE username = @Usuario 
          AND Password = CONVERT(NVARCHAR(50), HashBytes('SHA1', @Contraseña), 2)
          AND Estatus = 1;
END

go
CREATE PROCEDURE SP_ObtenerArtistaPorId
    @IdArtista INT
AS
BEGIN
    SELECT 
        Nombre AS NombreArtista,
        IdPais AS Idpais
    FROM 
        ARTISTA A
    WHERE 
        A.Id = @IdArtista;
END;
GO

DECLARE @IdArtista INT
SET @IdArtista = 1 -- Aquí define el ID del artista que deseas buscar
Exec SP_ObtenerArtistaPorId @IdArtista

GO
CREATE PROCEDURE SP_ActualizarArtista
    @Id INT,
    @Nombre NVARCHAR(50),
    @IdPais INT,
    @idUsuarioModifica INT
AS
BEGIN
    UPDATE ARTISTA
    SET 
        Nombre = @Nombre,
        IdPais = @IdPais,
        IdUsuarioModifica = @idUsuarioModifica,
        FechaModifica = GETDATE()
    WHERE
        Id = @Id;
END;
GO
CREATE PROCEDURE SP_EliminarArtista
    @Id INT,
    @IdUsuarioModifica INT
AS
BEGIN
    UPDATE ARTISTA
    SET 
        Estatus = 0,
        IdUsuarioModifica = @IdUsuarioModifica,
        FechaModifica = GETDATE()
    WHERE
        Id = @Id;
END;


