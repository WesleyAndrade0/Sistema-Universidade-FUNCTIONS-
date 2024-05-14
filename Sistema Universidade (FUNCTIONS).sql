CREATE DATABASE IF NOT EXISTS Universidade;
USE Universidade;

CREATE TABLE IF NOT EXISTS Area (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS Curso (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) UNIQUE,
    area_id INT,
    FOREIGN KEY (area_id) REFERENCES Area(id)
);

CREATE TABLE IF NOT EXISTS Aluno (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    sobrenome VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE IF NOT EXISTS Matricula (
    id INT PRIMARY KEY AUTO_INCREMENT,
    aluno_id INT,
    curso_id INT,
    data_matricula TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (aluno_id) REFERENCES Aluno(id),
    FOREIGN KEY (curso_id) REFERENCES Curso(id),
    UNIQUE (aluno_id, curso_id)
);

DELIMITER //

CREATE PROCEDURE InserirCurso (
    IN nome_curso VARCHAR(100),
    IN nome_area VARCHAR(100)
)
BEGIN
    DECLARE area_id INT;
    
    SELECT id INTO area_id FROM Area WHERE nome = nome_area;
    
    IF area_id IS NULL THEN
        INSERT INTO Area (nome) VALUES (nome_area);
        SET area_id = LAST_INSERT_ID();
    END IF;
    
    INSERT INTO Curso (nome, area_id) VALUES (nome_curso, area_id);
END //

DELIMITER ;

CREATE FUNCTION ObterIdCurso (nome_curso VARCHAR(100), nome_area VARCHAR(100))
RETURNS INT
BEGIN
    DECLARE curso_id INT;
    
    SELECT id INTO curso_id FROM Curso 
    WHERE nome = nome_curso 
    AND area_id = (SELECT id FROM Area WHERE nome = nome_area);
    
    RETURN curso_id;
END;

DELIMITER //

CREATE PROCEDURE MatricularAluno (
    IN nome_aluno VARCHAR(100),
    IN sobrenome_aluno VARCHAR(100),
    IN email_aluno VARCHAR(100),
    IN nome_curso VARCHAR(100),
    IN nome_area VARCHAR(100)
)
BEGIN
    DECLARE aluno_id INT;
    DECLARE curso_id INT;
    
    SELECT id INTO aluno_id FROM Aluno WHERE email = email_aluno;
    
    IF aluno_id IS NULL THEN
        INSERT INTO Aluno (nome, sobrenome, email) VALUES (nome_aluno, sobrenome_aluno, email_aluno);
        SET aluno_id = LAST_INSERT_ID();
    END IF;
    
    SET curso_id = ObterIdCurso(nome_curso, nome_area);
    
    IF curso_id IS NOT NULL THEN
        INSERT INTO Matricula (aluno_id, curso_id) VALUES (aluno_id, curso_id);
    END IF;
END //

DELIMITER ;

INSERT INTO Aluno (nome, sobrenome, email)
SELECT CONCAT('Aluno', id), CONCAT('Sobrenome', id), CONCAT('aluno', id, '.sobrenome', id, '@dominio.com')
FROM (SELECT @row := @row + 1 as id FROM Aluno, (SELECT @row := 0) r LIMIT 200) as ids;

INSERT INTO Curso (nome, area_id)
SELECT CONCAT('Curso', id), FLOOR((id - 1) / 5) + 1
FROM (SELECT @row := @row + 1 as id FROM Curso, (SELECT @row := 0) r LIMIT 25) as ids;
