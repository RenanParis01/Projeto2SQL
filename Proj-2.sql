-- Criação do BD
CREATE DATABASE IF NOT EXISTS supermercado_fp;
USE supermercado_fp;

-- Clientes (PF e PJ)
CREATE TABLE cliente (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  tipo ENUM('PF','PJ') NOT NULL,
  nome VARCHAR(100) NOT NULL,
  sobrenome VARCHAR(100),
  razao_social VARCHAR(150),
  cpf CHAR(11),
  cnpj CHAR(14),
  email VARCHAR(120),
  telefone VARCHAR(15),
  CONSTRAINT uq_cpf_cliente UNIQUE (cpf),
  CONSTRAINT uq_cnpj_cliente UNIQUE (cnpj),
  CONSTRAINT chk_pf_pj CHECK (
    (tipo = 'PF' AND cpf IS NOT NULL AND cnpj IS NULL) OR
    (tipo = 'PJ' AND cnpj IS NOT NULL AND cpf IS NULL)
  )
);

-- Endereço (um para muitos com cliente)
CREATE TABLE endereco_cliente (
  id_endereco INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  logradouro VARCHAR(150) NOT NULL,
  numero VARCHAR(10) NOT NULL,
  complemento VARCHAR(60),
  bairro VARCHAR(60) NOT NULL,
  cidade VARCHAR(60) NOT NULL,
  estado CHAR(2) NOT NULL,
  cep CHAR(8) NOT NULL,
  CONSTRAINT fk_end_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- Fornecedores
CREATE TABLE fornecedor (
  id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
  nome_fantasia VARCHAR(120) NOT NULL,
  razao_social VARCHAR(150) NOT NULL,
  cnpj CHAR(14) NOT NULL,
  telefone VARCHAR(15),
  email VARCHAR(120),
  CONSTRAINT uq_cnpj_fornecedor UNIQUE (cnpj)
);

-- Categorias de produto
CREATE TABLE categoria (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL,
  descricao VARCHAR(255)
);

-- Produtos
CREATE TABLE produto (
  id_produto INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  id_categoria INT NOT NULL,
  id_fornecedor INT NOT NULL,
  unidade ENUM('UN','KG','L','PACOTE','CAIXA') NOT NULL,
  preco_unit DECIMAL(10,2) NOT NULL,
  avaliacao DECIMAL(3,2) DEFAULT 0,
  ativo TINYINT(1) DEFAULT 1,
  CONSTRAINT fk_prod_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
  CONSTRAINT fk_prod_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor)
);

-- Estoque por filial
CREATE TABLE filial (
  id_filial INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cidade VARCHAR(60) NOT NULL,
  estado CHAR(2) NOT NULL
);

CREATE TABLE estoque (
  id_estoque INT AUTO_INCREMENT PRIMARY KEY,
  id_filial INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL DEFAULT 0,
  minimo INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_estoque_filial FOREIGN KEY (id_filial) REFERENCES filial(id_filial),
  CONSTRAINT fk_estoque_produto FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
  CONSTRAINT uq_filial_produto UNIQUE (id_filial, id_produto)
);

-- Empregados e departamentos
CREATE TABLE departamento (
  id_departamento INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(80) NOT NULL
);

CREATE TABLE empregado (
  id_empregado INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  sobrenome VARCHAR(100),
  cpf CHAR(11) UNIQUE,
  cargo VARCHAR(80) NOT NULL,
  salario DECIMAL(10,2) NOT NULL,
  id_departamento INT NOT NULL,
  id_filial INT NOT NULL,
  CONSTRAINT fk_emp_depart FOREIGN KEY (id_departamento) REFERENCES departamento(id_departamento),
  CONSTRAINT fk_emp_filial FOREIGN KEY (id_filial) REFERENCES filial(id_filial)
);

-- Pedidos (vendas)
CREATE TABLE pedido (
  id_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_filial INT NOT NULL,
  data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Aberto','Processando','Concluido','Cancelado') DEFAULT 'Aberto',
  valor_total DECIMAL(12,2) DEFAULT 0,
  CONSTRAINT fk_ped_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT fk_ped_filial FOREIGN KEY (id_filial) REFERENCES filial(id_filial)
);

-- Itens de pedido
CREATE TABLE pedido_item (
  id_pedido INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL,
  preco_unit DECIMAL(10,2) NOT NULL,
  desconto_pct DECIMAL(5,2) DEFAULT 0,
  PRIMARY KEY (id_pedido, id_produto),
  CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
  CONSTRAINT fk_item_prod FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

-- Pagamentos (múltiplos por pedido)
CREATE TABLE pagamento (
  id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  forma ENUM('Dinheiro','CartaoCredito','CartaoDebito','PIX','Boleto') NOT NULL,
  valor DECIMAL(12,2) NOT NULL,
  status ENUM('Autorizado','Negado','Pendente') DEFAULT 'Autorizado',
  CONSTRAINT fk_pag_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
);

-- Entregas (para pedidos de delivery)
CREATE TABLE entrega (
  id_entrega INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  status ENUM('Criada','Despachada','EmTransito','Entregue','Cancelada') DEFAULT 'Criada',
  codigo_rastreio VARCHAR(40),
  data_prevista DATE,
  data_entrega DATE,
  CONSTRAINT fk_ent_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
);

-- Filiais
INSERT INTO filial (nome, cidade, estado) VALUES
('Super FP - Centro', 'São Paulo', 'SP'),
('Super FP - Lapa', 'São Paulo', 'SP'),
('Super FP - Vitória', 'Vitória', 'ES');

-- Departamentos
INSERT INTO departamento (nome) VALUES
('Caixa'), ('Perecíveis'), ('Hortifruti'), ('Açougue'), ('Padaria'), ('Administrativo');

-- Empregados
INSERT INTO empregado (nome, sobrenome, cpf, cargo, salario, id_departamento, id_filial) VALUES
('Ana', 'Pereira', '12345678901', 'Caixa', 2500.00, 1, 1),
('Bruno', 'Silva', '98765432100', 'Gerente', 6500.00, 6, 1),
('Carla', 'Lima', '11122233344', 'Padeiro', 3200.00, 5, 2),
('Diego', 'Souza', '55566677788', 'Açougueiro', 3400.00, 4, 3);

-- Clientes PF
INSERT INTO cliente (tipo, nome, sobrenome, cpf, email, telefone) VALUES
('PF','Marina','Alves','01234567890','marina.alves@email.com','11999990000'),
('PF','Rafael','Costa','09876543210','rafael.costa@email.com','11988881111');

-- Clientes PJ
INSERT INTO cliente (tipo, razao_social, cnpj, email, telefone, nome) VALUES
('PJ','Padaria Doce Sabor LTDA','11222333000144','contato@docesabor.com','1122334455','Padaria Doce Sabor'),
('PJ','Restaurante Bom Gosto ME','55667788000122','contato@bomgosto.com','11911223344','Restaurante Bom Gosto');

-- Endereços
INSERT INTO endereco_cliente (id_cliente, logradouro, numero, complemento, bairro, cidade, estado, cep) VALUES
(1,'Rua das Flores','120','Apto 12','Centro','São Paulo','SP','01001000'),
(2,'Av. Paulista','1500',NULL,'Bela Vista','São Paulo','SP','01310000'),
(3,'Rua Pães','50',NULL,'Jardins','São Paulo','SP','01420000'),
(4,'Rua Gosto','92',NULL,'Centro','São Paulo','SP','01002000');

-- Fornecedores
INSERT INTO fornecedor (nome_fantasia, razao_social, cnpj, telefone, email) VALUES
('Delícia Alimentos','Delícia Alimentos SA','12345678000190','1133334444','vendas@delicia.com'),
('Tech Fria','Tech Fria Equipamentos LTDA','22334455000111','1144445555','comercial@techfria.com'),
('VerdeVida','VerdeVida Hortifruti ME','33445566000122','1177778888','contato@verdevida.com');

-- Categorias
INSERT INTO categoria (nome, descricao) VALUES
('Hortifruti','Frutas, legumes e verduras'),
('Perecíveis','Laticínios e resfriados'),
('Padaria','Pães e confeitaria'),
('Limpeza','Produtos de limpeza');

-- Produtos
INSERT INTO produto (nome, id_categoria, id_fornecedor, unidade, preco_unit, avaliacao, ativo) VALUES
('Banana Nanica', 1, 3, 'KG', 7.99, 4.8, 1),
('Leite Integral 1L', 2, 1, 'L', 5.49, 4.2, 1),
('Pão Francês', 3, 1, 'KG', 14.90, 4.6, 1),
('Detergente Neutro 500ml', 4, 1, 'UN', 3.99, 4.0, 1),
('Iogurte Natural 170g', 2, 1, 'UN', 2.99, 3.9, 1);

-- Estoque por filial
INSERT INTO estoque (id_filial, id_produto, quantidade, minimo) VALUES
(1,1,120,30),
(1,2,200,50),
(1,4,500,100),
(2,3,80,20),
(2,2,150,40),
(3,5,70,20);

-- Pedidos
INSERT INTO pedido (id_cliente, id_filial, status) VALUES
(1,1,'Concluido'),
(2,1,'Concluido'),
(3,2,'Processando');

-- Itens de pedido
-- Preço unitário replicado do produto na data da venda, com descontos variados
INSERT INTO pedido_item (id_pedido, id_produto, quantidade, preco_unit, desconto_pct) VALUES
(1,1,2,7.99,0),
(1,2,3,5.49,5.00),
(1,4,1,3.99,0),
(2,3,1,14.90,0),
(2,2,2,5.49,0),
(3,5,6,2.99,10.00);

-- Ajuste de valor_total dos pedidos (derivado dos itens)
UPDATE pedido p
JOIN (
  SELECT id_pedido,
         SUM(quantidade * preco_unit * (1 - desconto_pct/100)) AS total
  FROM pedido_item
  GROUP BY id_pedido
) t ON t.id_pedido = p.id_pedido
SET p.valor_total = t.total;

-- Pagamentos
INSERT INTO pagamento (id_pedido, forma, valor, status) VALUES
(1,'CartaoCredito', (SELECT valor_total FROM pedido WHERE id_pedido = 1), 'Autorizado'),
(2,'PIX', (SELECT valor_total FROM pedido WHERE id_pedido = 2), 'Autorizado'),
(3,'CartaoDebito', (SELECT valor_total FROM pedido WHERE id_pedido = 3), 'Autorizado');

-- Entregas (somente para pedidos de delivery, exemplo)
INSERT INTO entrega (id_pedido, status, codigo_rastreio, data_prevista) VALUES
(1,'Entregue','SPX123456789','2025-11-20'),
(2,'EmTransito','SPX987654321','2025-11-21');

-- 1) Recuperações simples com SELECT
SELECT id_produto, nome, preco_unit FROM produto WHERE ativo = 1 ORDER BY nome;

-- 2) Filtros com WHERE (estoque baixo em qualquer filial)
SELECT e.id_filial, f.nome AS filial, p.nome AS produto, e.quantidade, e.minimo
FROM estoque e
JOIN filial f ON f.id_filial = e.id_filial
JOIN produto p ON p.id_produto = e.id_produto
WHERE e.quantidade < e.minimo
ORDER BY f.nome, p.nome;

-- 3) Atributos derivados (valor item e valor com desconto)
SELECT 
  pi.id_pedido,
  p.nome AS produto,
  pi.quantidade,
  pi.preco_unit,
  pi.desconto_pct,
  (pi.quantidade * pi.preco_unit) AS valor_bruto,
  (pi.quantidade * pi.preco_unit * (1 - pi.desconto_pct/100)) AS valor_liquido
FROM pedido_item pi
JOIN produto p ON p.id_produto = pi.id_produto
ORDER BY pi.id_pedido, p.nome;

-- 4) Ordenações com ORDER BY (top produtos por avaliação)
SELECT id_produto, nome, avaliacao
FROM produto
WHERE ativo = 1
ORDER BY avaliacao DESC, nome ASC;

-- 5) Junções para perspectiva complexa (pedido, cliente, filial)
SELECT 
  ped.id_pedido,
  ped.data_pedido,
  ped.status,
  c.tipo,
  COALESCE(CONCAT(c.nome, ' ', c.sobrenome), c.razao_social) AS cliente,
  f.nome AS filial,
  ped.valor_total
FROM pedido ped
JOIN cliente c ON c.id_cliente = ped.id_cliente
JOIN filial f ON f.id_filial = ped.id_filial
ORDER BY ped.data_pedido DESC;

-- 6) Grupos com HAVING (clientes que gastaram mais de 50)
SELECT 
  c.id_cliente,
  COALESCE(CONCAT(c.nome, ' ', c.sobrenome), c.razao_social) AS cliente,
  SUM(ped.valor_total) AS total_gasto
FROM cliente c
JOIN pedido ped ON ped.id_cliente = c.id_cliente
GROUP BY c.id_cliente, cliente
HAVING SUM(ped.valor_total) > 50
ORDER BY total_gasto DESC;

-- 7) Quantos pedidos por cliente (PF e PJ)
SELECT 
  c.id_cliente,
  c.tipo,
  COALESCE(CONCAT(c.nome, ' ', c.sobrenome), c.razao_social) AS cliente,
  COUNT(ped.id_pedido) AS qtde_pedidos
FROM cliente c
LEFT JOIN pedido ped ON ped.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.tipo, cliente
ORDER BY qtde_pedidos DESC;

-- 8) Relação de produtos, fornecedores e estoque por filial
SELECT 
  p.id_produto,
  p.nome AS produto,
  cat.nome AS categoria,
  fz.nome_fantasia AS fornecedor,
  fl.nome AS filial,
  e.quantidade
FROM produto p
JOIN categoria cat ON cat.id_categoria = p.id_categoria
JOIN fornecedor fz ON fz.id_fornecedor = p.id_fornecedor
JOIN estoque e ON e.id_produto = p.id_produto
JOIN filial fl ON fl.id_filial = e.id_filial
ORDER BY cat.nome, fz.nome_fantasia, p.nome;

-- 9) Nomes dos fornecedores e nomes dos produtos (com total itens vendidos)
SELECT 
  fz.nome_fantasia AS fornecedor,
  p.nome AS produto,
  SUM(pi.quantidade) AS total_vendido
FROM fornecedor fz
JOIN produto p ON p.id_fornecedor = fz.id_fornecedor
LEFT JOIN pedido_item pi ON pi.id_produto = p.id_produto
GROUP BY fz.nome_fantasia, p.nome
ORDER BY fornecedor, total_vendido DESC;

-- 10) Produtos mais vendidos por filial (HAVING para filtrar relevantes)
SELECT 
  fl.nome AS filial,
  p.nome AS produto,
  SUM(pi.quantidade) AS qtd_vendida
FROM pedido_item pi
JOIN pedido ped ON ped.id_pedido = pi.id_pedido
JOIN filial fl ON fl.id_filial = ped.id_filial
JOIN produto p ON p.id_produto = pi.id_produto
GROUP BY fl.nome, p.nome
HAVING SUM(pi.quantidade) >= 2
ORDER BY fl.nome, qtd_vendida DESC;

-- 11) Verificar se algum empregado também é fornecedor (com mesmo CNPJ/CPF hipotético)
-- Supondo comparação entre CPF do empregado e CNPJ do fornecedor não faz sentido,
-- então exemplo: nomes coincidentes como sinal de alerta (apenas ilustrativo)
SELECT 
  e.nome AS empregado_nome,
  fz.nome_fantasia AS fornecedor_nome
FROM empregado e
JOIN fornecedor fz ON fz.nome_fantasia LIKE CONCAT('%', e.nome, '%');

-- 12) Ticket médio por cliente (valor total / número de pedidos)
SELECT
  c.id_cliente,
  COALESCE(CONCAT(c.nome, ' ', c.sobrenome), c.razao_social) AS cliente,
  COUNT(ped.id_pedido) AS pedidos,
  SUM(ped.valor_total) AS gasto_total,
  CASE WHEN COUNT(ped.id_pedido) = 0 THEN 0
       ELSE ROUND(SUM(ped.valor_total) / COUNT(ped.id_pedido), 2)
  END AS ticket_medio
FROM cliente c
LEFT JOIN pedido ped ON ped.id_cliente = c.id_cliente
GROUP BY c.id_cliente, cliente
ORDER BY ticket_medio DESC;

-- 13) Itens com desconto aplicado
SELECT 
  ped.id_pedido,
  p.nome AS produto,
  pi.quantidade,
  pi.preco_unit,
  pi.desconto_pct
FROM pedido_item pi
JOIN produto p ON p.id_produto = pi.id_produto
JOIN pedido ped ON ped.id_pedido = pi.id_pedido
WHERE pi.desconto_pct > 0
ORDER BY ped.id_pedido, p.nome;

-- 14) Estoque total por produto (somando filiais)
SELECT 
  p.id_produto,
  p.nome,
  SUM(e.quantidade) AS estoque_total
FROM produto p
JOIN estoque e ON e.id_produto = p.id_produto
GROUP BY p.id_produto, p.nome
HAVING SUM(e.quantidade) > 100
ORDER BY estoque_total DESC;

-- 15) Pagamentos por forma (com valor total e pedidos atendidos)
SELECT 
  pg.forma,
  COUNT(pg.id_pagamento) AS pagamentos,
  SUM(pg.valor) AS total_pago
FROM pagamento pg
GROUP BY pg.forma
ORDER BY total_pago DESC;


