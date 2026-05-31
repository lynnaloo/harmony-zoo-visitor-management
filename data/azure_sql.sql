-- 1. Create the Exhibit Status Table
CREATE TABLE Exhibit_Status (
    Exhibit_ID VARCHAR(15) PRIMARY KEY,
    Exhibit_Name VARCHAR(100) NOT NULL,
    Current_Status VARCHAR(50) NOT NULL,
    Last_Maintenance_Date DATE,
    Zone VARCHAR(50)
);

-- 2. Create the Animal Roster Table
CREATE TABLE Animal_Roster (
    Animal_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Species VARCHAR(100) NOT NULL,
    Age INT,
    Diet_Type VARCHAR(100),
    Exhibit_ID VARCHAR(15),
    FOREIGN KEY (Exhibit_ID) REFERENCES Exhibit_Status(Exhibit_ID)
);

-- 3. Insert Harmony City Zoo Exhibits
INSERT INTO Exhibit_Status (Exhibit_ID, Exhibit_Name, Current_Status, Last_Maintenance_Date, Zone)
VALUES 
('EXH-AC-001', 'Arctic Coast Exhibit', 'Open', '2026-03-01', 'North Wing'),
('EXH-SP-002', 'Savanna Plains', 'Open', '2026-02-15', 'East Meadow'),
('EXH-EY-003', 'Elephant Yard', 'Open', '2026-03-10', 'South Loop'),
('EXH-RH-004', 'Reptile House', 'Open', '2026-01-22', 'Central Court'),
('EXH-AV-005', 'Tropical Aviary', 'Closed - Maintenance', '2026-03-28', 'West Grove'),
('EXH-ACQ-006', 'Aquarium Gallery', 'Open', '2026-02-05', 'North Wing Lower'),
('EXH-PR-007', 'Primate Ridge', 'Open', '2026-03-15', 'Central Ridge'),
('EXH-CH-008', 'Children''s Habitat', 'Open', '2026-03-20', 'Family Zone'),
('EXH-INC-009', 'Insectarium', 'Open', '2026-02-28', 'West Grove'),
('EXH-RV-010', 'River Otter Run', 'Open', '2026-01-15', 'North Stream'),
('EXH-ZP-011', 'Zebra Panda Exhibit', 'Open', '2026-03-25', 'Special Exhibits Hall');

-- 4. Insert Harmony City Zoo Animals
INSERT INTO Animal_Roster (Name, Species, Age, Diet_Type, Exhibit_ID)
VALUES 
-- Arctic Coast (EXH-AC-001)
('Nanook', 'Polar Bear', 8, 'Carnivore', 'EXH-AC-001'),
('Pippin', 'Emperor Penguin', 4, 'Piscivore', 'EXH-AC-001'),

-- Savanna Plains (EXH-SP-002)
('Twiga', 'Giraffe', 7, 'Herbivore (Acacia Leaves)', 'EXH-SP-002'),
('Zola', 'Zebra', 5, 'Herbivore', 'EXH-SP-002'),
('Leo', 'African Lion', 6, 'Carnivore', 'EXH-SP-002'),

-- Elephant Yard (EXH-EY-003)
('Tembo', 'African Elephant', 15, 'Herbivore', 'EXH-EY-003'),

-- Reptile House (EXH-RH-004)
('Sly', 'Komodo Dragon', 12, 'Carnivore', 'EXH-RH-004'),
('Shelly', 'Sea Turtle', 35, 'Omnivore', 'EXH-RH-004'),

-- Tropical Aviary (EXH-AV-005)
('Mango', 'Toucan', 3, 'Frugivore', 'EXH-AV-005'),
('Rio', 'Parrot', 10, 'Omnivore', 'EXH-AV-005'),

-- Primate Ridge (EXH-PR-007)
('Koko', 'Western Lowland Gorilla', 14, 'Vegetarian', 'EXH-PR-007'),
('Budi', 'Orangutan', 9, 'Frugivore', 'EXH-PR-007'),
('Momo', 'Lemur', 4, 'Omnivore', 'EXH-PR-007'),

-- River Otter Run (EXH-RV-010)
('Splash', 'River Otter', 3, 'Piscivore (Shellfish)', 'EXH-RV-010'),

-- Special Exhibits Hall (EXH-ZP-011)
('Oreo', 'Zebra Panda', 5, 'Herbivore (Bamboo)', 'EXH-ZP-011');