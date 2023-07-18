IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Bolnica')
BEGIN
    CREATE DATABASE Bolnica;
END
GO

USE Bolnica;

CREATE TABLE Lijekovi (
  ID_Lijek INT PRIMARY KEY,
  Naziv_Lijek VARCHAR(255),
  Doza VARCHAR(50),
  Opis VARCHAR(MAX)
);

CREATE TABLE Odjel (
  ID_Odjel INT PRIMARY KEY,
  Naziv_odjela VARCHAR(255),
  Odjel_šef VARCHAR(255)
);

CREATE TABLE Pacijenti (
  PacijentID INT PRIMARY KEY,
  Ime VARCHAR(255),
  Prezime VARCHAR(255),
  Datum_rodenja DATE,
  Spol CHAR(1),
  Adresa VARCHAR(255),
  Telefon VARCHAR(20),
  Email VARCHAR(255)
);

CREATE TABLE Doktori (
  DoktorID INT PRIMARY KEY,
  Ime_doktora VARCHAR(255),
  Prezime_doktora VARCHAR(255),
  Specijalizacija VARCHAR(255),
  Doktor_odijel INT,
  FOREIGN KEY (Doktor_odijel) REFERENCES Odjel(ID_Odjel)
);

CREATE TABLE Termini (
  TerminID INT PRIMARY KEY,
  Datum_termina DATE,
  Vrijeme_termina TIME,
  Pacijent_termin INT,
  Doktor_termin INT,
  Lijek INT,
  FOREIGN KEY (Pacijent_termin) REFERENCES Pacijenti(PacijentID),
  FOREIGN KEY (Doktor_termin) REFERENCES Doktori(DoktorID),
  FOREIGN KEY (Lijek) REFERENCES Lijekovi(ID_Lijek)
);
GO

--------TRIGERI I PROCEDURE-------
GO
CREATE TRIGGER trg_Lijekovi_Insert
ON Lijekovi
AFTER INSERT
AS
BEGIN
  DECLARE @ID_Lijek INT, @Naziv_Lijek VARCHAR(255);
  
  SELECT @ID_Lijek = ID_Lijek, @Naziv_Lijek = Naziv_Lijek
  FROM inserted;
  
  PRINT 'Ubacili smo novi lijek - ID: ' + CAST(@ID_Lijek AS VARCHAR) + ', Ime: ' + @Naziv_Lijek;
END;
GO

GO
CREATE TRIGGER trg_NakonAzuriranja
ON Termini
AFTER UPDATE 
AS
BEGIN
  DECLARE @TerminID INT, @PacijentID INT;

  SELECT @TerminID = TerminID, @PacijentID = Pacijent_termin
  FROM inserted;

  PRINT 'Zapis ažuriran - TerminID: ' + CAST(@TerminID AS VARCHAR) + ', Novi PacijentID: ' + CAST(@PacijentID AS VARCHAR);
END;

GO

GO
CREATE TRIGGER trg_UmjestoUnosa
ON Lijekovi
INSTEAD OF INSERT
AS
BEGIN
  SET NOCOUNT ON;
  
  INSERT INTO Lijekovi (ID_Lijek, Naziv_Lijek, Doza, Opis)
  SELECT ID_Lijek, UPPER(Naziv_Lijek), Doza, Opis
  FROM inserted;
  
  DECLARE @ID_Lijek INT, @Naziv_Lijek VARCHAR(255);
  
  SELECT @ID_Lijek = ID_Lijek, @Naziv_Lijek = Naziv_Lijek
  FROM inserted;
  
  PRINT 'Ubacili smo novi lijek - ID: ' + CAST(@ID_Lijek AS VARCHAR) + ', Ime: ' + @Naziv_Lijek;
END;
GO

GO
CREATE TRIGGER trg_Pacijenti_Insert
ON Pacijenti
AFTER INSERT
AS
BEGIN
  DECLARE @PacijentID INT, @Ime VARCHAR(255), @Prezime VARCHAR(255);
  
  SELECT @PacijentID = PacijentID, @Ime = Ime, @Prezime = Prezime
  FROM inserted;
  
  PRINT 'Ubacili smo novog pacijenta - ID: ' + CAST(@PacijentID AS VARCHAR) + ', Ime: ' + @Ime + ', Prezime: ' + @Prezime;
END;
GO

GO
CREATE PROCEDURE DodajOdjel
    @ID_Odjel INT,
    @Naziv_odjela VARCHAR(255),
    @Odjel_sef VARCHAR(255)
AS
BEGIN
    INSERT INTO Odjel (ID_Odjel, Naziv_odjela, Odjel_šef)
    VALUES (@ID_Odjel, @Naziv_odjela, @Odjel_sef);
    
    PRINT 'Novi odjel je uspješno dodan.';
END
GO


GO
CREATE PROCEDURE DeleteDoctor
    @DoktorID INT
AS
BEGIN
    DELETE FROM Doktori
    WHERE DoktorID = @DoktorID;
END
GO

GO
CREATE FUNCTION BrojPacijenataUTerminu(@TerminID INT)
RETURNS INT
AS
BEGIN
    DECLARE @BrojPacijenata INT;
    
    SELECT @BrojPacijenata = COUNT(DISTINCT Pacijent_termin)
    FROM Termini
    WHERE TerminID = @TerminID;
    
    RETURN @BrojPacijenata;
END
GO

GO
CREATE PROCEDURE DodajTermin
    @TerminID INT,
    @DatumTermina DATE,
    @VrijemeTermina TIME,
    @PacijentID INT,
    @DoktorID INT,
    @LijekID INT
AS
BEGIN
    INSERT INTO Termini (TerminID, Datum_termina, Vrijeme_termina, Pacijent_termin, Doktor_termin, Lijek)
    VALUES (@TerminID, @DatumTermina, @VrijemeTermina, @PacijentID, @DoktorID, @LijekID);
END
GO

GO
CREATE PROCEDURE AzurirajTermin
    @TerminID INT,
    @Datum_termina DATE,
    @Vrijeme_termina TIME,
    @Pacijent_termin INT,
    @Doktor_termin INT,
    @Lijek INT
AS
BEGIN
    UPDATE Termini
    SET Datum_termina = @Datum_termina,
        Vrijeme_termina = @Vrijeme_termina,
        Pacijent_termin = @Pacijent_termin,
        Doktor_termin = @Doktor_termin,
        Lijek = @Lijek
    WHERE TerminID = @TerminID;
END
GO

GO
INSERT INTO Lijekovi (ID_Lijek, Naziv_Lijek, Doza, Opis)
VALUES
  (1, 'Paracetamol', '500 mg', 'Lijek za ublažavanje boli i snižavanje tjelesne temperature'),
  (2, 'Ibuprofen', '400 mg', 'Lijek protiv bolova, upala i groznice'),
  (3, 'Amoksicilin', '500 mg', 'Antibiotik za lijecenje infekcija');
GO

GO
INSERT INTO Odjel (ID_Odjel, Naziv_odjela, Odjel_šef)
VALUES
  (1, 'Interna medicina', 'Dr. Novak'),
  (2, 'Kirurgija', 'Dr. Kovacic'),
  (3, 'Ginekologija', 'Dr. Horvat'),
  (4,'Kardiologija', 'Dr. Guzina');
GO

GO
INSERT INTO Pacijenti (PacijentID, Ime, Prezime, Datum_roðenja, Spol, Adresa, Telefon, Email)
VALUES
  (1, 'Ana', 'Kovacevic', '1985-03-10', 'Ž', 'Ulica 123', '01-234-5678', 'ana@example.com'),
  (2, 'Marko', 'Petrovic', '1992-08-22', 'M', 'Trg 456', '01-987-6543', 'marko@example.com'),
  (3, 'Maja', 'Horvat', '1980-11-05', 'Ž', 'Avenija 789', '01-333-9999', 'maja@example.com'),
  (4, 'Ivo', 'Zadro', '1945-04-20','M', 'Domovinska 23','01-832-1234','zadro@example.hr');
GO

GO
INSERT INTO Doktori (DoktorID, Ime_doktora, Prezime_doktora, Specijalizacija, Doktor_odijel)
VALUES
  (1, 'Ivan', 'Babic', 'Opca medicina', 1),
  (2, 'Marija', 'Kovac', 'Dermatologija', 1),
  (3, 'Ante', 'Vukovic', 'Ortopedija', 2),
  (4, 'Rene', 'Bitorajac', 'Kardiovaskularni kirurg',4);
GO

GO
INSERT INTO Termini (TerminID, Datum_termina, Vrijeme_termina, Pacijent_termin, Doktor_termin, Lijek)
VALUES
  (1, '2023-05-15', '10:00', 1, 1, 1),
  (2, '2023-05-16', '14:30', 2, 1, 2),
  (3, '2023-05-17', '09:15', 3, 2, 3);
go

GO
BEGIN TRAN;

INSERT INTO Lijekovi (ID_Lijek, Naziv_Lijek, Doza, Opis)
VALUES (4, 'Aspirin', '100 mg', 'Lijek za ublažavanje boli i smanjenje upala');

EXEC DodajOdjel 5, 'Pedijatrija', 'Dr. Petrovic';

INSERT INTO Pacijenti (PacijentID, Ime, Prezime, Datum_roðenja, Spol, Adresa, Telefon, Email)
VALUES (5, 'Ivana', 'Petrovic', '1990-06-15', 'Ž', 'Gajeva 789', '01-555-8888', 'ivana@example.com');

INSERT INTO Doktori (DoktorID, Ime_doktora, Prezime_doktora, Specijalizacija, Doktor_odijel)
VALUES (5, 'Petar', 'Kovac', 'Dermatologija', 3);

DECLARE @BrojPacijenata INT;
SET @BrojPacijenata = dbo.BrojPacijenataUTerminu(1);
PRINT 'Broj pacijenata u terminu 1: ' + CAST(@BrojPacijenata AS VARCHAR);

EXEC AzurirajTermin 1, '2023-05-15', '10:30', 2, 3, 2;

IF @@ROWCOUNT > 0
    PRINT 'Termin je uspješno ažuriran.';
ELSE
    PRINT 'Termin nije pronaden.';

ROLLBACK TRAN;
