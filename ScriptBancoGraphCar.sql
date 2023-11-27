-- SQLBook: Code
-- Active: 1685408949990@@localhost@3306@graphcar
/*DROP USER 'GraphUser'@'%';
DELETE FROM mysql.user where user = 'GraphUser';
*/
CREATE USER 'GraphUser'@'%' IDENTIFIED BY 'Graph2023';
GRANT ALL PRIVILEGES ON GraphCar.* TO 'GraphUser'@'%';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS GraphCar;
USE GraphCar;

CREATE TABLE Usuario(
	idUsuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    senha VARCHAR(64),
    cpf CHAR (11) UNIQUE,
    foto VARCHAR(200), 
    nivelAcesso TINYINT
);

CREATE TABLE ModeloCarro(
	idModelo INT PRIMARY KEY AUTO_INCREMENT,
    modelo VARCHAR(30),
    versaoSoftware VARCHAR(60)
);

CREATE TABLE Carro(
	idCarro INT PRIMARY KEY AUTO_INCREMENT,
    placa VARCHAR(15) UNIQUE,
	fkUsuario INT,
    fkModelo INT,
    CONSTRAINT fhkUsuario FOREIGN KEY (fkUsuario) REFERENCES Usuario(idUsuario),
    CONSTRAINT fhkModelo FOREIGN KEY (fkModelo) REFERENCES ModeloCarro(idModelo)
);

CREATE TABLE Componentes(
	idComponentes INT PRIMARY KEY AUTO_INCREMENT,
    nomeComponente VARCHAR(10),
    versaoDriver VARCHAR(15),
    unidade VARCHAR(10)
);

CREATE TABLE Medida(
	idMedida INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(20),
    unidade VARCHAR(20),
    limiteAlerta DECIMAL(5,2),
    limiteCritico DECIMAL(5,2),
    meta DECIMAL(4,1)
);

CREATE TABLE Servidor(
	idServidor INT PRIMARY KEY AUTO_INCREMENT,
    modeloServidor VARCHAR(45) NOT NULL,
    hostname VARCHAR(45),
    mac CHAR(12),
    finalidadeServidor VARCHAR(45),
    sistemaOperacional VARCHAR(45),
    dataCriacao DATETIME
);

CREATE TABLE DadosServidor(
	idDadosServidor INT PRIMARY KEY AUTO_INCREMENT,
    cpuUso DECIMAL(5,2),
    cpuTemperatura DECIMAL(5,2),
    memoria DECIMAL(5,2),
    disco DECIMAL(5,2),
    dateDado DATETIME,
    fkServidor INT,
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE Processos(
	idProcessos INT PRIMARY KEY AUTO_INCREMENT,
    nomeProcesso VARCHAR(45),
    grupoProcesso VARCHAR(45),
    fkDadosServidor INT,
    FOREIGN KEY (fkDadosServidor) REFERENCES DadosServidor(idDadosServidor)
);

CREATE TABLE ModeloComponente(
	idModeloComponente INT PRIMARY KEY AUTO_INCREMENT,
    fkComponente INT,
    fkModeloCarro INT NULL,
    fkServidor INT NULL,
    FOREIGN KEY(fkComponente) REFERENCES Componentes(idComponentes),
    FOREIGN KEY(fkModeloCarro) REFERENCES ModeloCarro(idModelo),
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor)
);

CREATE TABLE MedidaModeloComponente(
	fkModeloComponente INT,
    fkMedida INT,
    FOREIGN KEY (fkModeloComponente) REFERENCES ModeloComponente(idModeloComponente),
    FOREIGN KEY (fkMedida) REFERENCES Medida(idMedida),
    PRIMARY KEY (fkModeloComponente, fkMedida)
);

CREATE TABLE Dados(
	idDados INT PRIMARY KEY AUTO_INCREMENT,
    cpuUso DECIMAL(5,2),
    cpuTemperatura DECIMAL(5,2),
    gpuUso DECIMAL(5,2),
    gpuTemperatura DECIMAL(5,2),
    memoria DECIMAL(5,2),
    bateriaNivel DECIMAL(5,2),
    bateriaTaxa DECIMAL(5,2),
    bateriaTempoRestante INT,
    dateDado DATETIME,
    fkCarro INT,
    CONSTRAINT fkCarro FOREIGN KEY (fkCarro) REFERENCES Carro(idCarro)
);

CREATE TABLE Chamado(
    idChamado INT PRIMARY KEY AUTO_INCREMENT,
    fkServidor INT,
    fkComponente INT,
    chaveJira VARCHAR(15),
    status VARCHAR(30),
    encerrado TINYINT,
    critico TINYINT,
    dataAbertura DATETIME,
    ultimaMensagemSlack DATETIME,
    FOREIGN KEY (fkServidor) REFERENCES Servidor(idServidor),
    FOREIGN KEY (fkComponente) REFERENCES Componentes(idComponentes)
);

-- Fim das tabelas!

/* SELECT idDados, 
	MAX(CASE WHEN fkComponentes = 1 THEN dado END) AS "CPU",
	MAX(CASE WHEN fkComponentes = 2 THEN dado END) AS "RAM",
	MAX(CASE WHEN fkComponentes = 3 THEN dado END) AS "Disco"
FROM Dados GROUP BY idDados; */

DELIMITER //
CREATE PROCEDURE CADASTRAR_MOTORISTA(IN 
	US_NOME VARCHAR(50), 
    US_EMAIL VARCHAR(100), 
    US_SENHA VARCHAR(64), 
	US_CPF VARCHAR(11),
    US_FOTO VARCHAR(100),
    US_NIVELACESSO TINYINT, 
    C_PLACA VARCHAR(15), 
    MC_MODELO INT
    
    ) BEGIN 
	INSERT INTO usuario (nome, email, senha, cpf, foto, nivelAcesso)
	VALUES ( us_nome, us_email, us_senha, us_CPF, us_foto, us_nivelacesso);
	INSERT INTO Carro (placa , fkUsuario, fkModelo)
	VALUES ( c_placa,
    (SELECT idUsuario FROM usuario WHERE email = us_email),
    mc_modelo);
	END// 
DELIMITER ;

INSERT INTO ModeloCarro (idModelo, modelo) VALUES (NULL, 'Model S'),
                                                  (NULL, 'Model 3'),
                                                  (NULL, 'Model X'),
                                                  (NULL, 'Model Y');


CALL CADASTRAR_MOTORISTA ('ADM', 'admin@graphcar.com', '123456789', 
'55555555555', 'user.png', 4, 'AAA 9999', 1);
CALL CADASTRAR_MOTORISTA ('Carlos Pereira', 'carlos.pereira@graphcar.com', '$2b$10$M/CbWCDYZcYYDnTUs1nfPOu/U665hzfQDSBucm56MxAy4ldau2YAi', 
'46781235945', 'user.png', 3, 'BCD 6458', 2);

INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "CPU");
INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "RAM");
INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "Disco");
INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "GPU");
INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "Bateria");

INSERT INTO Medida (nome, unidade, limiteAlerta, limiteCritico, meta) VALUES 
	("temperatura", "°C", 70, 90, 5),
    ("uso", "%", 70, 90, 10),
    ("uso", "%", 20, 5, 5);

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

CREATE OR REPLACE VIEW alertas_gerais AS
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

CREATE OR REPLACE VIEW alertas_ultimo_mes AS
SELECT CONCAT(DAY(dateDado),"/", MONTH(dateDado)) as dia, 
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
	FROM Dados WHERE dateDado > DATE_SUB(now(), INTERVAL 30 DAY) GROUP BY dia;

CREATE OR REPLACE VIEW dados_como_alerta AS
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
    
CREATE OR REPLACE VIEW alertas_cpu AS
    SELECT idDados, fkCarro, cpuAlerta FROM dados_como_alerta dca1 
    WHERE dca1.cpuAlerta > (SELECT cpuAlerta FROM dados_como_alerta dca2 WHERE dca1.fkCarro = dca2.fkCarro AND dca2.idDados = 
    (SELECT MAX(dca3.idDados) FROM dados_como_alerta AS dca3 WHERE dca3.fkCarro = dca1.fkCarro AND dca3.idDados < dca1.idDados));
    
CREATE OR REPLACE VIEW alerta_atual AS
	SELECT d1.* FROM Dados d1 JOIN ( SELECT fkCarro, MAX(dateDado) AS ultimaHora 
	FROM Dados GROUP BY fkCarro) d2 ON
    d2.fkCarro = d1.fkCarro AND d2.ultimaHora = d1.dateDado WHERE d1.dateDado > DATE_SUB(now(), INTERVAL 15 DAY_MINUTE);

CREATE OR REPLACE VIEW alertas_concatenados AS 
	SELECT fkCarro, 
    CONCAT(DAY(dateDado),"/", MONTH(dateDado)) as dia, 
    GROUP_CONCAT(cpuAlerta) AS cpuConcat, 
    GROUP_CONCAT(gpuAlerta) AS gpuConcat,
    GROUP_CONCAT(memoriaAlerta) AS memoriaConcat,
    GROUP_CONCAT(bateriaNivelAlerta) AS bateriaNivelConcat
    FROM dados_como_alerta WHERE dateDado > DATE_SUB(now(), INTERVAL 30 DAY) GROUP BY fkCarro, dia;

CREATE OR REPLACE VIEW metas_dashboard AS
	SELECT (SELECT COUNT(idCarro) FROM Carro) AS count_carro, 
	(SELECT meta FROM Medida WHERE idMedida = 2) AS meta_cpu, 
	(SELECT meta FROM Medida WHERE idMedida = 2) AS meta_gpu, 
	(SELECT meta FROM Medida WHERE idMedida = 3) AS meta_bat;
    
CREATE OR REPLACE VIEW tempo_chamados AS
	SELECT idChamado, fkServidor, fkComponente,
		CASE WHEN encerrado = 1
			THEN TIMEDIFF(ultimaMensagemSlack, dataAbertura)
            ELSE TIMEDIFF(now(), dataAbertura) END AS tempo
		FROM Chamado;
        
CREATE OR REPLACE VIEW tempo_chamados_porcent AS
	SELECT s.idServidor AS idServidor, tc.fkComponente AS idComponente, 
		100 * SUM(tc.tempo) / TIMEDIFF(now(), s.dataCriacao) AS tempoPorcent
    FROM tempo_chamados tc INNER JOIN Servidor s 
    ON s.idServidor = tc.fkServidor GROUP BY idServidor, idComponente;
    
SELECT * FROM dados_como_alerta;
SELECT * FROM alertas_ultimo_mes;
SELECT * FROM alertas_cpu;

SELECT idModelo,
            u.* FROM Usuario u
            LEFT JOIN Carro ON Carro.fkUsuario = u.idUsuario
            LEFT JOIN ModeloCarro ON Carro.fkModelo = ModeloCarro.idModelo
            WHERE u.email = 'h@gmail.com';

SELECT  idModelo,
            idUsuario, 
            nome,
            foto
            FROM Usuario u 
            JOIN Carro ON Carro.fkUsuario = u.idUsuario
            JOIN ModeloCarro ON Carro.fkModelo = ModeloCarro.idModelo
            WHERE idUsuario = 5;

SELECT * FROM Carro 
        JOIN Modelocarro 
        JOIN Usuario ON fkModelo = idModelo and idUsuario = fkUsuario;


SET @lista_componentes = (SELECT GROUP_CONCAT( (
	CONCAT(
		"MAX(CASE WHEN fkComponentes = ", Componentes.idComponentes, " THEN ROUND(dado, 2) END) AS '", Componentes.nomeComponente, "'"
	)
) SEPARATOR ", ") FROM Componentes
);

-- SET @comando_sql = CONCAT('CREATE VIEW dados_por_componente AS
-- SELECT idDados, dateDado, ', @lista_componentes, ' FROM Dados GROUP BY idDados, dateDado;');
        
-- PREPARE stmt FROM @comando_sql;

-- EXECUTE stmt;