BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;

-- Tabela TB_TIPO_FONTES
CREATE TABLE tb_tipo_fontes (
    id_tipo_fonte INT GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    nome_fonte VARCHAR2(50),
    CONSTRAINT tb_tipo_fontes_id_tipo_fonte_pk PRIMARY KEY (id_tipo_fonte)
);

-- Tabela TB_REGIOES_SUSTENTAVEIS
CREATE TABLE tb_regioes_sustentaveis (
    id_regiao INT GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    nome_regiao VARCHAR2(50),
    CONSTRAINT tb_regioes_sustentaveis_id_regiao_pk PRIMARY KEY (id_regiao)
);

-- Tabela TB_EMISSOES_CARBONO
CREATE TABLE tb_emissoes_carbono (
    id_emissao INT GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    id_tipo_fonte INT NOT NULL,
    emissao NUMBER(10, 2),
    CONSTRAINT tb_emissoes_carbono_id_emissao_pk PRIMARY KEY (id_emissao),
    CONSTRAINT tb_emissoes_carbono_id_tipo_fonte_fk FOREIGN KEY (id_tipo_fonte)
        REFERENCES tb_tipo_fontes (id_tipo_fonte)
);

-- Tabela TB_PROJETOS_SUSTENTAVEIS
CREATE TABLE tb_projetos_sustentaveis (
    id_projeto INT GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    id_tipo_fonte INT,
    id_regiao INT,
    descricao_projeto VARCHAR2(255),
    custo_projeto NUMBER(20, 2),
    status_projeto VARCHAR2(50),
    CONSTRAINT tb_projetos_sustentaveis_id_projeto_pk PRIMARY KEY (id_projeto),
    CONSTRAINT tb_projetos_sustentaveis_id_tipo_fonte_fk FOREIGN KEY (id_tipo_fonte)
        REFERENCES tb_tipo_fontes (id_tipo_fonte),
    CONSTRAINT tb_projetos_sustentaveis_id_regiao_fk FOREIGN KEY (id_regiao)
        REFERENCES tb_regioes_sustentaveis (id_regiao)
);

INSERT INTO tb_tipo_fontes (nome_fonte)
SELECT nome AS nome_fonte FROM PF0645.TIPO_FONTES;

INSERT INTO tb_regioes_sustentaveis (nome_regiao)
SELECT nome AS nome_regiao FROM PF0645.regioes_sustentaveis;

INSERT INTO tb_emissoes_carbono (id_tipo_fonte, emissao)
SELECT id_tipo_fonte, emissao FROM PF0645.emissoes_carbono;

INSERT INTO tb_projetos_sustentaveis (id_tipo_fonte, id_regiao, descricao_projeto, custo_projeto, status_projeto)
SELECT id_tipo_fonte, id_regiao, descricao AS descricao_projeto, custo AS custo_projeto, status AS status_projeto FROM PF0645.projetos_sustentaveis;

-- Tabela TB_EMPRESAS
CREATE TABLE tb_empresas (
    id_empresa INT GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    nome_empresa VARCHAR2(100) NOT NULL,
    cnpj_empresa VARCHAR2(14) NOT NULL,
    senha_empresa VARCHAR(20) NOT NULL,
    CONSTRAINT tb_empresas_id_empresa_pk PRIMARY KEY(id_empresa),
    CONSTRAINT tb_empresas_cnpj_empresa_uc UNIQUE(cnpj_empresa)
);

-- Tabela TB_COMUNIDADES
CREATE TABLE tb_comunidades (
    id_comunidade INT GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    id_empresa INT NOT NULL,
    id_regiao INT NOT NULL,
    protocolo_atendimento_comunidade INT,
    nome_comunidade VARCHAR2(100) NOT NULL,
    latitude_comunidade NUMBER(7,5) NOT NULL,
    longitude_comunidade NUMBER(8,5) NOT NULL,
    CONSTRAINT tb_comunidades_id_comunidade_pk PRIMARY KEY(id_comunidade),
    CONSTRAINT tb_comunidades_id_empresa_fk FOREIGN KEY(id_empresa)
        REFERENCES tb_empresas (id_empresa),
    CONSTRAINT tb_comunidades_id_regiao_fk FOREIGN KEY(id_regiao)
        REFERENCES tb_regioes_sustentaveis (id_regiao)
);

-- Tabela associativa TB_COMUNIDADES e TB_PROJETOS_SUSTENTAVEIS
CREATE TABLE tb_comunidades_projetos (
    id_comunidade INT NOT NULL,
    id_projeto INT NOT NULL,
    CONSTRAINT tb_comunidades_projetos_id_comunidade FOREIGN KEY (id_comunidade)
        REFERENCES tb_comunidades (id_comunidade),
    CONSTRAINT tb_comunidades_projetos_id_projeto FOREIGN KEY (id_projeto)
        REFERENCES tb_projetos_sustentaveis (id_projeto)
);

-- Tabela TB_SENSORES
CREATE TABLE tb_sensores (
    id_sensor INT GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    id_comunidade INT NOT NULL,
    id_tipo_fonte INT NOT NULL,
    tipo_sensor VARCHAR2(30) NOT NULL
        CHECK (tipo_sensor IN ('Produção', 'Armazenamento', 'Consumo')),
    descricao_sensaor VARCHAR2(100),
    CONSTRAINT tb_sensores_id_pk PRIMARY KEY (id_sensor),
    CONSTRAINT tb_sensores_id_comunidade_fk FOREIGN KEY (id_comunidade)
        REFERENCES tb_comunidades (id_comunidade),
    CONSTRAINT tb_sensores_id_tipo_fonte_fk FOREIGN KEY (id_tipo_fonte)
        REFERENCES tb_tipo_fontes (id_tipo_fonte)
);

-- Tabela TB_MEDICOES
CREATE TABLE tb_medicoes (
    id_medicao INT GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
    id_comunidade INT NOT NULL,
    id_sensor INT NOT NULL,
    tipo_medicao VARCHAR2(30) NOT NULL
        CHECK (tipo_medicao IN ('Produção', 'Armazenamento', 'Consumo')),
    valor_medicao INT NOT NULL,
    data_hora_medicao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tb_medicoes_id_medicao_pk PRIMARY KEY(id_medicao),
    CONSTRAINT tb_medicoes_id_comunidade_fk FOREIGN KEY(id_comunidade)
        REFERENCES tb_comunidades (id_comunidade),
    CONSTRAINT tb_medicoes_id_medidor_fk FOREIGN KEY(id_sensor)
        REFERENCES tb_sensores (id_sensor)
);