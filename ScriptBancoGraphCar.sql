-- Active: 1685408949990@@localhost@3306@graphcar
DROP USER 'GraphUser'@'localhost';
DELETE FROM mysql.user where user = 'GraphUser';

CREATE USER 'GraphUser'@'localhost' IDENTIFIED BY 'Graph2023';
GRANT ALL PRIVILEGES ON GraphCar.* TO 'GraphUser'@'localhost';
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
    foto VARCHAR(100), 
    nivelAcesso TINYINT
);

CREATE TABLE ModeloCarro(
	idModelo INT PRIMARY KEY AUTO_INCREMENT,
    Modelo VARCHAR(30),
    VersaoSoftware VARCHAR(60)
);

CREATE TABLE Carro(
	idCarro INT PRIMARY KEY AUTO_INCREMENT,
    Placa VARCHAR(15) UNIQUE,
	fkUsuario INT,
    fkModelo INT,
    CONSTRAINT fhkUsuario FOREIGN KEY (fkUsuario) REFERENCES Usuario(idUsuario),
    CONSTRAINT fhkModelo FOREIGN KEY (fkModelo) REFERENCES ModeloCarro(idModelo)
);

CREATE TABLE Componentes(
	idComponentes INT PRIMARY KEY AUTO_INCREMENT,
    NomeComponente VARCHAR(10),
    descricao VARCHAR(20),
    VersaoDriver VARCHAR(15),
    fkModelo INT,
    FOREIGN KEY (fkModelo) REFERENCES ModeloCarro(idModelo)
);

CREATE TABLE Dados(
	idDados INT PRIMARY KEY AUTO_INCREMENT,
    dado FLOAT,
    medida VARCHAR(10),
    dateDado DATETIME,
    fkCarro INT,
    fkComponentes INT,
    CONSTRAINT fhkCarro FOREIGN KEY (fkCarro) REFERENCES Carro(idCarro),
    CONSTRAINT fhkComponentes FOREIGN KEY (fkComponentes) REFERENCES Componentes(idComponentes)
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
    MC_MODELO VARCHAR(30)
    
    ) BEGIN 
	INSERT INTO usuario (nome, email, senha, CPF, foto, nivelAcesso)
	VALUES ( us_nome, us_email, us_senha, us_CPF, us_foto, us_nivelacesso);
    -- INSERT INTO ModeloCarro (Modelo)
    -- VALUES (mc_modelo);
	INSERT INTO Carro (Placa , fkUsuario, fkModelo)
	VALUES ( c_placa,
    (SELECT idUsuario FROM usuario WHERE email = us_email),
    (SELECT idModelo FROM ModeloCarro WHERE modelo = mc_modelo));
	END// 
DELIMITER ;

INSERT INTO modelocarro (idModelo, modelo) VALUES (NULL, 'Model S'),
                                                  (NULL, 'Model 3'),
                                                  (NULL, 'Model X'),
                                                  (NULL, 'Model Y');


CALL CADASTRAR_MOTORISTA ('ADM', 'admin@graphcar.com', '$2b$10$M/CbWCDYZcYYDnTUs1nfPOu/U665hzfQDSBucm56MxAy4ldau2YAi', 
'55555555555', 'user.png', 3, 'AAA 9999', 'Model S');

INSERT INTO Componentes (idComponentes, nomeComponente, descricao, fkModelo) VALUES (NULL, "CPU", 'AMD Zen 1', 1);
INSERT INTO Componentes (idComponentes, nomeComponente, descricao, fkModelo) VALUES (NULL, "RAM", '32 Gb',1);
INSERT INTO Componentes (idComponentes, nomeComponente, descricao, fkModelo) VALUES (NULL, "Disco", '1 Tb', 1);
INSERT INTO Componentes (idComponentes, nomeComponente, descricao, fkModelo) VALUES (NULL, "GPU", 'Navi 23 GPU RDNA 2', 1);

SELECT NomeComponente, descricao FROM componentes 
        JOIN modelocarro ON fkModelo = idModelo WHERE idModelo = 1;

SELECT * FROM carro 
        JOIN modelocarro 
        JOIN usuario ON fkModelo = idModelo and idUsuario = fkUsuario 

SELECT * FROM usuario;
SELECT * FROM modelocarro;
select * from Dados;
select * from Componentes;

SET @lista_componentes = (SELECT GROUP_CONCAT( (
	CONCAT(
		"MAX(CASE WHEN fkComponentes = ", Componentes.idComponentes, " THEN ROUND(dado, 2) END) AS '", Componentes.nomeComponente, "'"
	)
) SEPARATOR ", ") FROM Componentes
);

SET @comando_sql = CONCAT('CREATE VIEW dados_por_componente AS
SELECT idDados, dateDado, ', @lista_componentes, ' FROM Dados GROUP BY idDados, dateDado;');
        
PREPARE stmt FROM @comando_sql;

EXECUTE stmt;