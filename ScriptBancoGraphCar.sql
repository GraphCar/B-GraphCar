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
    foto VARCHAR(100), 
    adm TINYINT
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

DELIMITER //
CREATE PROCEDURE CADASTRAR_MOTORISTA(IN 
	US_NOME VARCHAR(50), 
    US_EMAIL VARCHAR(100), 
    US_SENHA VARCHAR(64), 
	US_CPF VARCHAR(11),
    US_ADM TINYINT, 
    C_PLACA VARCHAR(15), 
    MC_MODELO VARCHAR(30)
    
    ) BEGIN 
	INSERT INTO usuario (nome, email, senha, CPF, adm)
	VALUES ( us_nome, us_email, us_senha, us_CPF, us_adm);
    INSERT INTO ModeloCarro (Modelo)
    VALUES (mc_modelo);
	INSERT INTO Carro (Placa , fkUsuario, fkModelo)
	VALUES ( c_placa,
    (SELECT idUsuario FROM usuario WHERE email = us_email),
    (SELECT idModelo FROM ModeloCarro WHERE idModelo = (SELECT idUsuario FROM usuario WHERE email = us_email)));
	END// 
DELIMITER ;
INSERT INTO Usuario (nome, email, senha, cpf, adm) values ('ADM', 'admin@graphcar.com', '$2b$10$M/CbWCDYZcYYDnTUs1nfPOu/U665hzfQDSBucm56MxAy4ldau2YAi', '000', 3);

INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "CPU");
INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "RAM");
INSERT INTO Componentes (idComponentes, nomeComponente) VALUES (NULL, "Disco");




select * from Dados;
select * from Componentes;
