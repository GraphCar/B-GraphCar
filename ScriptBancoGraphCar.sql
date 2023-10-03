-- SQLBook: Code
-- Active: 1685408949990@@localhost@3306@graphcar
DROP USER 'GraphUser'@'%';
DELETE FROM mysql.user where user = 'GraphUser';

CREATE USER 'GraphUser'@'%' IDENTIFIED BY 'Graph2023';
GRANT ALL PRIVILEGES ON GraphCar.* TO 'GraphUser'@'%';
FLUSH PRIVILEGES;

DROP DATABASE IF EXISTS GraphCar;
CREATE DATABASE GraphCar;
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

CREATE TABLE ModeloComponente(
	idModeloComponente INT PRIMARY KEY AUTO_INCREMENT,
    fkComponente INT,
    fkModeloCarro INT,
    FOREIGN KEY(fkComponente) REFERENCES Componentes(idComponentes),
    FOREIGN KEY(fkModeloCarro) REFERENCES ModeloCarro(idModelo)
    );

CREATE TABLE Dados(
	idDados INT PRIMARY KEY AUTO_INCREMENT,
    cpuUso DECIMAL(5,2),
    cpuTemperatura DECIMAL(5,2),
    gpuUso DECIMAL(5,2),
    gpuTemperatura DECIMAL(5,2),
    memoria DECIMAL(7,2),
    bateriaNivel DECIMAL(5,2),
    bateriaTaxa DECIMAL(7,2),
    dateDado DATETIME,
    fkCarro INT,
    CONSTRAINT fkCarro FOREIGN KEY (fkCarro) REFERENCES Carro(idCarro)
);

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
	INSERT INTO usuario (nome, email, senha, CPF, foto, nivelAcesso)
	VALUES ( us_nome, us_email, us_senha, us_CPF, us_foto, us_nivelacesso);
	INSERT INTO Carro (Placa , fkUsuario, fkModelo)
	VALUES ( c_placa,
    (SELECT idUsuario FROM usuario WHERE email = us_email),
    mc_modelo);
	END// 
DELIMITER ;

INSERT INTO modelocarro (idModelo, modelo) VALUES (NULL, 'Model S'),
                                                  (NULL, 'Model 3'),
                                                  (NULL, 'Model X'),
                                                  (NULL, 'Model Y');


CALL CADASTRAR_MOTORISTA ('ADM', 'admin@graphcar.com', '$2b$10$M/CbWCDYZcYYDnTUs1nfPOu/U665hzfQDSBucm56MxAy4ldau2YAi', 
'55555555555', 'user.png', 3, 'AAA 9999', 1);

INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "CPU");
INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "RAM");
INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "Disco");
INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "GPU");

INSERT INTO modelocomponente(fkComponente, fkModeloCarro) VALUES (1, 1), (2, 1), (3, 1), (4, 1),
                                                                 (1, 2), (2, 2), (3, 2), (4, 2),
                                                                 (1, 3), (2, 3), (3, 3), (4, 3),
                                                                 (1, 4), (2, 4), (3, 4), (4, 4);

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
SELECT CONCAT(DAY(dateDado),"/", MONTH(dateDado)) as dia, SUM(CASE WHEN cpuUso > 70 THEN 1 ELSE 0 END) as cpuAlerta,
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


SELECT * FROM alertas_ultimo_mes;

SELECT idModelo,
            u.* FROM usuario u
            LEFT JOIN carro ON carro.fkUsuario = u.idUsuario
            LEFT JOIN modeloCarro ON carro.fkModelo = modeloCarro.idModelo
            WHERE u.email = 'h@gmail.com';

SELECT  idModelo,
            idUsuario, 
            nome,
            foto
            FROM usuario u 
            JOIN Carro ON carro.fkUsuario = u.idUsuario
            JOIN ModeloCarro ON carro.fkModelo = modeloCarro.idModelo
            WHERE idUsuario = 5;

SELECT * FROM carro 
        JOIN modelocarro 
        JOIN usuario ON fkModelo = idModelo and idUsuario = fkUsuario;

SELECT * FROM usuario;
SELECT * FROM modelocarro;
select * from Dados;
UPDATE Dados SET cpuUso = 75.0 WHERE idDados BETWEEN 78 AND 85;
select * from Componentes;
select * from modelocomponente;

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