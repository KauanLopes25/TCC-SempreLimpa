-- =========================================================
-- INSERTS
-- =========================================================

-- STATUS

INSERT INTO status (descricao)
VALUES
('PENDENTE'),
('PAGO'),
('EM_ANDAMENTO'),
('FINALIZADO'),
('CANCELADO');

-- ENDEREÇOS USUÁRIOS

INSERT INTO endereco (
    cep,
    uf,
    cidade,
    bairro,
    logradouro,
    numero,
    complemento
)
VALUES
('06657300','SP','Itapevi','Rosemary','Rua Serra do Paracaima','1374',NULL),
('06650000','SP','Jandira','Centro','Rua das Flores','200',NULL),
('06400000','SP','Barueri','Alphaville','Av Alpha','1000','Bloco A');

-- ENDEREÇOS LAVANDERIAS

INSERT INTO endereco_lavanderia (
    cep,
    uf,
    cidade,
    bairro,
    logradouro,
    numero,
    complemento
)
VALUES
('01001000','SP','São Paulo','Centro','Praça da Sé','100','Sala 1'),
('04538132','SP','São Paulo','Itaim Bibi','Av Brigadeiro Faria Lima','3477','Térreo'),
('01310100','SP','São Paulo','Bela Vista','Av Paulista','1500','Loja A');

-- ENDEREÇOS MOTORISTA

INSERT INTO endereco_motorista (
    cep,
    uf,
    cidade,
    bairro,
    logradouro,
    numero,
    complemento
)
VALUES
(
    '06657000',
    'SP',
    'Itapevi',
    'Centro',
    'Rua José Michelotti',
    '120',
    'Casa 1'
),
(
    '06454000',
    'SP',
    'Barueri',
    'Alphaville',
    'Av. Andrômeda',
    '850',
    'Apartamento 12'
),
(
    '06010000',
    'SP',
    'Osasco',
    'Vila Yara',
    'Rua dos Autonomistas',
    '450',
    'Bloco B'
),
(
    '06700000',
    'SP',
    'Cotia',
    'Granja Viana',
    'Estrada da Capuava',
    '77',
    NULL
),
(
    '06110000',
    'SP',
    'Carapicuíba',
    'Centro',
    'Rua XV de Novembro',
    '300',
    'Fundos'
);

-- USUÁRIOS

INSERT INTO usuario (
    nome,
    e_mail,
    telefone,
    cpf,
    rne,
    fk_endereco,
    senha
)
VALUES
('Weslei','weslei@email.com','11984106174','57030864859',NULL,1,'weslei123'),
('Maria Silva','maria@email.com','11987654321','12345678901',NULL,2,'maria123'),
('João Santos','joao@email.com','11991234567','98765432100',NULL,3,'joao123');

-- LAVANDERIAS

INSERT INTO lavanderia (
    nome,
    descricao,
    cnpj,
    tempo_padrao_lavagem,
    tempo_secagem,
    preco_padrao_lavagem,
    preco_padrao_secagem,
    logo,
    e_mail,
    telefone,
    fk_endereco_lavanderia
)
VALUES
(
    '5asec',
    'Lavagem premium',
    '04078995000245',
    '01:00:00',
    '00:30:00',
    30.00,
    15.00,
    'logo1.png',
    '5asec@test.com',
    '11999999998',
    1
),
(
    'White Bubble',
    'Lavagem ecológica',
    '12345678000199',
    '01:30:00',
    '00:40:00',
    25.50,
    12.00,
    'logo2.png',
    'bubble@test.com',
    '11988888888',
    2
),
(
    'Super Clean',
    'Lavagem pesada',
    '98765432000188',
    '02:00:00',
    '01:00:00',
    40.00,
    20.00,
    'logo3.png',
    'superclean@test.com',
    '11977777777',
    3
);

-- CARTÕES

INSERT INTO cartao (
    usuario_id,
    bandeira,
    validade,
    token_cartao,
    ultimos_digitos
)
VALUES
(
    1,
    'MASTER',
    '1228',
    'token_abc123',
    '4562'
);

-- FAVORITOS

INSERT INTO favoritos (
    fk_usuario_id,
    fk_lavanderia_id
)
VALUES
(1,1),
(1,2),
(2,3);

-- AVALIAÇÕES

INSERT INTO avaliacao (
    nota,
    comentario,
    fk_usuario_id,
    fk_lavanderia_id
)
VALUES
(5,'Excelente serviço',1,1),
(4,'Muito boa',1,2),
(3,'Pode melhorar',2,3);

-- PEDIDOS

INSERT INTO pedido (
    valor_total,
    taxa_entrega,
    taxa_entregador,
    taxa_app,
    tempo_estimado,
    fk_status_id,
    fk_lavanderia_id,
    fk_usuario_id
)
VALUES
(
    50.00,
    10.00,
    5.00,
    6.00,
    '01:30:00',
    1,
    1,
    1
),
(
    80.00,
    15.00,
    7.00,
    6.00,
    '02:00:00',
    2,
    2,
    1
);

-- CESTO

INSERT INTO cesto (
    peso_estimado,
    secagem,
    tipo_lavagem,
    fk_pedido_id
)
VALUES
(5.5,'SIM','NORMAL',1),
(8.0,'NAO','PESADA',2);

-- ROUPAS

INSERT INTO roupas (
    nome_peca
)
VALUES
('Camiseta'),
('Calça'),
('Cobertor');

-- CESTO ROUPA

INSERT INTO cesto_roupa (
    fk_cesto_id,
    fk_roupas_id,
    quantidade
)
VALUES
(1,1,5),
(1,2,2),
(2,3,1);

-- ORDEM PAGAMENTO

INSERT INTO ordem_pagamento (
    tipo_pagamento,
    valor,
    status,
    fk_pedido_id
)
VALUES
('PIX',71.00,'PENDENTE',1),
('CARTAO',108.00,'PAGO',2);

-- PIX

INSERT INTO pix (
    chave_pix,
    data_expiracao,
    qr_code,
    status,
    fk_ordem_pagamento_id
)
VALUES
(
    'pix_123',
    DATE_ADD(NOW(), INTERVAL 30 MINUTE),
    'qr_code_pix',
    'PENDENTE',
    1
);

-- PAGAMENTO CARTÃO

INSERT INTO pagamento_cartao (
    token_utilizado,
    ultimos_digitos,
    tipo,
    fk_cartao_id,
    fk_ordem_pagamento_id
)
VALUES
(
    'token_abc123',
    '4562',
    'CREDITO',
    1,
    2
);