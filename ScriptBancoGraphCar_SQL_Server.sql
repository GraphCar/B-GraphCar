CREATE DATABASE [GraphCar];
USE GraphCar;

CREATE USER GraphUser WITH PASSWORD = 'Graph2023';
GRANT SELECT, INSERT, UPDATE, DELETE ON GraphCar TO GraphUser;

CREATE TABLE Usuario(
	idUsuario INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    senha VARCHAR(64),
    cpf CHAR (11) UNIQUE,
    foto VARCHAR(200), 
    nivelAcesso TINYINT
);

CREATE TABLE ModeloCarro(
	idModelo INT IDENTITY(1,1) PRIMARY KEY,
    modelo VARCHAR(30),
    versaoSoftware VARCHAR(60)
);

CREATE TABLE Carro(
	idCarro INT IDENTITY(1,1) PRIMARY KEY,
    placa VARCHAR(15) UNIQUE,
	fkUsuario INT FOREIGN KEY REFERENCES Usuario(idUsuario),
    fkModelo INT FOREIGN KEY REFERENCES ModeloCarro(idModelo)
);

CREATE TABLE Componentes(
	idComponentes INT IDENTITY(1,1) PRIMARY KEY,
    nomeComponente VARCHAR(10),
    versaoDriver VARCHAR(15),
    unidade VARCHAR(10)
);

CREATE TABLE Medida(
	idMedida INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(20),
    unidade VARCHAR(20),
    limiteAlerta DECIMAL(5,2),
    limiteCritico DECIMAL(5,2),
    meta DECIMAL(4,1)
);

CREATE TABLE Servidor(
	idServidor INT IDENTITY(1,1) PRIMARY KEY,
    modeloServidor VARCHAR(45) NOT NULL,
    hostname VARCHAR(45),
    mac CHAR(12),
    finalidadeServidor VARCHAR(45),
    sistemaOperacional VARCHAR(45),
    dataCriacao DATETIME
);

CREATE TABLE DadosServidor(
	idDadosServidor INT IDENTITY(1,1) PRIMARY KEY,
    cpuUso DECIMAL(5,2),
    cpuTemperatura DECIMAL(5,2),
    memoria DECIMAL(5,2),
    disco DECIMAL(5,2),
    dateDado DATETIME,
    fkServidor INT FOREIGN KEY REFERENCES Servidor(idServidor)
);

CREATE TABLE Processos(
	idProcessos INT IDENTITY(1,1) PRIMARY KEY,
    nomeProcesso VARCHAR(45),
    grupoProcesso VARCHAR(45),
    fkDadosServidor INT FOREIGN KEY REFERENCES DadosServidor(idDadosServidor)
);

CREATE TABLE ModeloComponente(
	idModeloComponente INT IDENTITY(1,1) PRIMARY KEY,
    fkComponente INT FOREIGN KEY REFERENCES Componentes(idComponentes),
    fkModeloCarro INT NULL FOREIGN KEY REFERENCES ModeloCarro(idModelo),
    fkServidor INT NULL FOREIGN KEY REFERENCES Servidor(idServidor)
);

CREATE TABLE MedidaModeloComponente(
	fkModeloComponente INT FOREIGN KEY REFERENCES ModeloComponente(idModeloComponente),
    fkMedida INT FOREIGN KEY REFERENCES Medida(idMedida),
    PRIMARY KEY (fkModeloComponente, fkMedida)
);

CREATE TABLE Dados(
	idDados INT IDENTITY(1,1) PRIMARY KEY,
    cpuUso DECIMAL(5,2),
    cpuTemperatura DECIMAL(5,2),
    gpuUso DECIMAL(5,2),
    gpuTemperatura DECIMAL(5,2),
    memoria DECIMAL(5,2),
    bateriaNivel DECIMAL(5,2),
    bateriaTaxa DECIMAL(5,2),
    bateriaTempoRestante INT,
    dateDado DATETIME,
    fkCarro INT FOREIGN KEY REFERENCES Carro(idCarro)
);

CREATE TABLE Chamado(
    idChamado INT IDENTITY(1,1) PRIMARY KEY,
    fkServidor INT FOREIGN KEY REFERENCES Servidor(idServidor),
    fkComponente INT FOREIGN KEY REFERENCES Componentes(idComponentes),
    chaveJira VARCHAR(15),
    status VARCHAR(30),
    encerrado TINYINT,
    critico TINYINT,
    dataAbertura DATETIME,
    ultimaMensagemSlack DATETIME
);

-- Fim das tabelas!

/* SELECT idDados, 
	MAX(CASE WHEN fkComponentes = 1 THEN dado END) AS 'CPU',
	MAX(CASE WHEN fkComponentes = 2 THEN dado END) AS 'RAM',
	MAX(CASE WHEN fkComponentes = 3 THEN dado END) AS 'Disco'
FROM Dados GROUP BY idDados; */

GO
CREATE PROCEDURE CADASTRAR_MOTORISTA
	@US_NOME VARCHAR(50), 
    @US_EMAIL VARCHAR(100), 
    @US_SENHA VARCHAR(64), 
	@US_CPF VARCHAR(11),
    @US_FOTO VARCHAR(100),
    @US_NIVELACESSO TINYINT, 
    @C_PLACA VARCHAR(15), 
    @MC_MODELO INT
AS
	INSERT INTO usuario (nome, email, senha, cpf, foto, nivelAcesso)
	VALUES ( @US_NOME, @US_EMAIL, @US_SENHA, @US_CPF, @US_FOTO, @US_NIVELACESSO);
	INSERT INTO Carro (placa , fkUsuario, fkModelo)
	VALUES ( @C_PLACA,
    (SELECT idUsuario FROM usuario WHERE email = @US_EMAIL),
    @MC_MODELO);
GO

INSERT INTO ModeloCarro (modelo) VALUES ('Model S'),
                                                  ('Model 3'),
                                                  ('Model X'),
                                                  ('Model Y');


EXECUTE CADASTRAR_MOTORISTA 'ADM', 'admin@graphcar.com', '123456789', 
'55555555555', 'user.png', 4, 'AAA 9999', 1;
EXECUTE CADASTRAR_MOTORISTA 'Carlos Pereira', 'carlos.pereira@graphcar.com', '$2b$10$M/CbWCDYZcYYDnTUs1nfPOu/U665hzfQDSBucm56MxAy4ldau2YAi', 
'46781235945', 'user.png', 3, 'BCD 6458', 2;
EXECUTE CADASTRAR_MOTORISTA 'Barbara Oliveira', 'barbara.oliveira@gmail.com', '$2b$10$M/CbWCDYZcYYDnTUs1nfPOu/U665hzfQDSBucm56MxAy4ldau2YAi', 
'10303836903', 'user.png', 1, 'ABC 1234', 2;
EXECUTE CADASTRAR_MOTORISTA 'Maria Almeida', 'maria.almeida@graphcar.com', '$2b$10$M/CbWCDYZcYYDnTUs1nfPOu/U665hzfQDSBucm56MxAy4ldau2YAi', 
'14121537615', 'user.png', 1, 'ABC 1235', 2;

INSERT INTO Componentes (nomeComponente) VALUES ('CPU');
INSERT INTO Componentes (nomeComponente) VALUES ('RAM');
INSERT INTO Componentes (nomeComponente) VALUES ('Disco');
INSERT INTO Componentes (nomeComponente) VALUES ('GPU');
INSERT INTO Componentes ( nomeComponente) VALUES ('Bateria');

INSERT INTO Medida (nome, unidade, limiteAlerta, limiteCritico, meta) VALUES 
	('temperatura', '°C', 70, 90, 5),
    ('uso', '%', 70, 90, 10),
    ('uso', '%', 20, 5, 5);

INSERT INTO ModeloComponente(fkModeloCarro, fkComponente) VALUES (1, 1), (2, 1), (3, 1), (4, 1),	-- CPU
                                                                 (1, 2), (2, 2), (3, 2), (4, 2),	-- RAM
                                                                 (1, 3), (2, 3), (3, 3), (4, 3),	-- Disco
                                                                 (1, 4), (2, 4), (3, 4), (4, 4),	-- GPU
                                                                 (1, 5), (2, 5), (3, 5), (4, 5);	-- Bateria

INSERT INTO MedidaModeloComponente (fkModeloComponente, fkMedida) VALUES
	(1,1), (1,2), (2,1), (2,2), (3,1), (3,2), (4,1), (4,2), 			-- CPU
    (5,2), (6,2), (7,2), (8,2),											-- RAM
    (9,2), (10,2), (11,2), (12,2), 										-- Disco
    (13,1), (13,2), (14,1), (14,2), (15,1), (15,2), (16,1), (16,2), 	-- GPU
    (17,3), (18,3), (19,3), (20,3); 									-- Bateria

GO
CREATE OR ALTER VIEW alertas_gerais AS
SELECT SUM(CASE WHEN cpuUso > 70 THEN 1 ELSE 0 END) as cpuAlerta,
	SUM(CASE WHEN cpuUso > 90 THEN 1 ELSE 0 END) as cpuCritico,
    SUM(CASE WHEN cpuTemperatura > 70 THEN 1 ELSE 0 END) as cpuTempAlerta,
    SUM(CASE WHEN cpuTemperatura > 90 THEN 1 ELSE 0 END) as cpuTempCritico,
    SUM(CASE WHEN gpuUso > 70 THEN 1 ELSE 0 END) as gpuAlerta,
    SUM(CASE WHEN gpuUso > 90 THEN 1 ELSE 0 END) as gpuCritico,
    SUM(CASE WHEN gpuTemperatura > 70 THEN 1 ELSE 0 END) as gpuTempAlerta,
    SUM(CASE WHEN gpuTemperatura > 90 THEN 1 ELSE 0 END) as gpuTempCritico,
    SUM(CASE WHEN memoria > 70 THEN 1 ELSE 0 END) as ramAlerta,
    SUM(CASE WHEN memoria > 90 THEN 1 ELSE 0 END) as ramCritico,
    SUM(CASE WHEN bateriaNivel < 20  THEN 1 ELSE 0 END) as bateriaAlerta,
    SUM(CASE WHEN bateriaNivel < 5 THEN 1 ELSE 0 END) as bateriaCritico,
    SUM(CASE WHEN bateriaTaxa > 70 THEN 1 ELSE 0 END) as bateriaTaxaAlerta,
    SUM(CASE WHEN bateriaTaxa > 90 THEN 1 ELSE 0 END) as bateriaTaxaCritico
	FROM Dados;
GO

GO
CREATE OR ALTER VIEW alertas_gerais_por_carro AS
SELECT fkCarro,
	SUM(CASE WHEN cpuUso > 70 THEN 1 ELSE 0 END) as cpuAlerta,
	SUM(CASE WHEN cpuUso > 90 THEN 1 ELSE 0 END) as cpuCritico,
    SUM(CASE WHEN cpuTemperatura > 70 THEN 1 ELSE 0 END) as cpuTempAlerta,
    SUM(CASE WHEN cpuTemperatura > 90 THEN 1 ELSE 0 END) as cpuTempCritico,
    SUM(CASE WHEN gpuUso > 70 THEN 1 ELSE 0 END) as gpuAlerta,
    SUM(CASE WHEN gpuUso > 90 THEN 1 ELSE 0 END) as gpuCritico,
    SUM(CASE WHEN gpuTemperatura > 70 THEN 1 ELSE 0 END) as gpuTempAlerta,
    SUM(CASE WHEN gpuTemperatura > 90 THEN 1 ELSE 0 END) as gpuTempCritico,
    SUM(CASE WHEN memoria > 70 THEN 1 ELSE 0 END) as ramAlerta,
    SUM(CASE WHEN memoria > 90 THEN 1 ELSE 0 END) as ramCritico,
    SUM(CASE WHEN bateriaNivel < 20  THEN 1 ELSE 0 END) as bateriaAlerta,
    SUM(CASE WHEN bateriaNivel < 5 THEN 1 ELSE 0 END) as bateriaCritico,
    SUM(CASE WHEN bateriaTaxa > 70 THEN 1 ELSE 0 END) as bateriaTaxaAlerta,
    SUM(CASE WHEN bateriaTaxa > 90 THEN 1 ELSE 0 END) as bateriaTaxaCritico
	FROM Dados GROUP BY fkCarro;
GO

GO
CREATE OR ALTER VIEW alertas_ultimo_mes AS
SELECT CONCAT(DAY(dateDado),'/', MONTH(dateDado)) as dia, 
	SUM(CASE WHEN cpuUso > 70 THEN 1 ELSE 0 END) as cpuAlerta,
	SUM(CASE WHEN cpuUso > 90 THEN 1 ELSE 0 END) as cpuCritico,
    SUM(CASE WHEN cpuTemperatura > 70 THEN 1 ELSE 0 END) as cpuTempAlerta,
    SUM(CASE WHEN cpuTemperatura > 90 THEN 1 ELSE 0 END) as cpuTempCritico,
    SUM(CASE WHEN gpuUso > 70 THEN 1 ELSE 0 END) as gpuAlerta,
    SUM(CASE WHEN gpuUso > 90 THEN 1 ELSE 0 END) as gpuCritico,
    SUM(CASE WHEN gpuTemperatura > 70 THEN 1 ELSE 0 END) as gpuTempAlerta,
    SUM(CASE WHEN gpuTemperatura > 90 THEN 1 ELSE 0 END) as gpuTempCritico,
    SUM(CASE WHEN memoria > 70 THEN 1 ELSE 0 END) as ramAlerta,
    SUM(CASE WHEN memoria > 90 THEN 1 ELSE 0 END) as ramCritico,
    SUM(CASE WHEN bateriaNivel < 20 THEN 1 ELSE 0 END) as bateriaAlerta,
    SUM(CASE WHEN bateriaNivel < 5 THEN 1 ELSE 0 END) as bateriaCritico,
    SUM(CASE WHEN bateriaTaxa > 70 THEN 1 ELSE 0 END) as bateriaTaxaAlerta,
    SUM(CASE WHEN bateriaTaxa > 90 THEN 1 ELSE 0 END) as bateriaTaxaCritico
	FROM Dados WHERE dateDado > DATEADD(DAY, -30, GETDATE()) GROUP BY CONCAT(DAY(dateDado),'/', MONTH(dateDado));
GO

GO
CREATE OR ALTER VIEW dados_como_alerta AS
SELECT idDados,
    CASE WHEN cpuUso > 90 THEN 2 ELSE (CASE WHEN cpuUso > 70 THEN 1 ELSE 0 END) END AS cpuAlerta,
    CASE WHEN cpuTemperatura > 90 THEN 2 ELSE (CASE WHEN cpuTemperatura > 70 THEN 1 ELSE 0 END) END AS cpuTempAlerta,
    CASE WHEN gpuUso > 90 THEN 2 ELSE (CASE WHEN gpuUso > 70 THEN 1 ELSE 0 END) END AS gpuAlerta,
    CASE WHEN gpuTemperatura > 90 THEN 2 ELSE (CASE WHEN gpuTemperatura > 70 THEN 1 ELSE 0 END) END AS gpuTempALerta,
    CASE WHEN memoria > 90 THEN 2 ELSE (CASE WHEN memoria > 70 THEN 1 ELSE 0 END) END AS memoriaAlerta,
	CASE WHEN bateriaNivel < 5 THEN 2 ELSE (CASE WHEN bateriaNivel < 20 THEN 1 ELSE 0 END) END AS bateriaNivelAlerta,
	CASE WHEN bateriaTaxa > 90 THEN 2 ELSE (CASE WHEN bateriaTaxa > 70 THEN 1 ELSE 0 END) END AS bateriaTaxaAlerta,
    dateDado,
    fkCarro FROM Dados;
GO

GO
CREATE OR ALTER VIEW alertas_cpu AS
    SELECT idDados, fkCarro, cpuAlerta FROM dados_como_alerta dca1 
    WHERE dca1.cpuAlerta > (SELECT cpuAlerta FROM dados_como_alerta dca2 WHERE dca1.fkCarro = dca2.fkCarro AND dca2.idDados = 
    (SELECT MAX(dca3.idDados) FROM dados_como_alerta AS dca3 WHERE dca3.fkCarro = dca1.fkCarro AND dca3.idDados < dca1.idDados));
GO

GO
CREATE OR ALTER VIEW alerta_atual AS
	SELECT d1.* FROM Dados d1 JOIN ( SELECT fkCarro, MAX(dateDado) AS ultimaHora 
	FROM Dados GROUP BY fkCarro) d2 ON
    d2.fkCarro = d1.fkCarro AND d2.ultimaHora = d1.dateDado WHERE d1.dateDado > DATEADD(minute, -15, GETDATE());
GO

GO
CREATE OR ALTER VIEW alertas_concatenados AS 
	SELECT fkCarro, 
    CONCAT(DAY(dateDado),'/', MONTH(dateDado)) as dia, 
    STRING_AGG(cpuAlerta, ',') AS cpuConcat, 
    STRING_AGG(gpuAlerta, ',') AS gpuConcat,
    STRING_AGG(memoriaAlerta, ',') AS memoriaConcat,
    STRING_AGG(bateriaNivelAlerta, ',') AS bateriaNivelConcat
    FROM dados_como_alerta WHERE dateDado > DATEADD(DAY, -30, GETDATE()) GROUP BY fkCarro, CONCAT(DAY(dateDado),'/', MONTH(dateDado));
GO

GO
CREATE OR ALTER VIEW metas_dashboard AS
	SELECT (SELECT COUNT(idCarro) FROM Carro) AS count_carro, 
	(SELECT meta FROM Medida WHERE idMedida = 2) AS meta_cpu, 
	(SELECT meta FROM Medida WHERE idMedida = 2) AS meta_gpu, 
	(SELECT meta FROM Medida WHERE idMedida = 3) AS meta_bat;
GO

GO
CREATE OR ALTER VIEW tempo_chamados AS
	SELECT idChamado, fkServidor, fkComponente,
		CASE WHEN encerrado = 1
			THEN DATEDIFF(second, ultimaMensagemSlack, dataAbertura)
            ELSE DATEDIFF(second, GETDATE(), dataAbertura) END AS tempo
		FROM Chamado;
GO

GO
CREATE OR ALTER VIEW tempo_chamados_porcent AS
	SELECT s.idServidor AS idServidor, tc.fkComponente AS idComponente, COUNT(idChamado) qtdeChamados,
		ROUND(100 * SUM(tc.tempo) / DATEDIFF(second, GETDATE(), s.dataCriacao),2) AS tempoPorcent
    FROM tempo_chamados tc INNER JOIN Servidor s 
    ON s.idServidor = tc.fkServidor GROUP BY s.idServidor, tc.fkComponente;
GO