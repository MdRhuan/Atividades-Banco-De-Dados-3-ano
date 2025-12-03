-- Cria um novo banco para o exercício.
Create Database atividade_boliche;
Use atividade_boliche;

-- Tabela que guarda as bolas na cesta.
Create Table cesta_bolas (
    bola_id Int Not Null Primary Key,
    cor Varchar(15) Not Null,
    total Int Not Null Default 0
) Engine=InnoDB Default Charset=utf8mb4;

Delimiter $$

-- Procedure para inserir bolinhas na cesta, com checagens de id, cor e capacidade.
Create Procedure pr_inserir_bola(
    In p_bola_id Int,
    In p_cor Varchar(15),
    In p_qt Int
)
Begin
    Declare v_soma Int Default 0;
    Declare v_capacidade Int Default 300;
    Declare v_novo_total Int;
    Declare v_existe Int Default 0;
    Declare v_espaco Int;
    
    -- Id deve estar entre 1 e 16.
    If p_bola_id Not Between 1 And 16 Then
        Signal Sqlstate '45002' Set Message_text = 'ID da bola deve ser 1–16';
    End If;
    
    -- Quantidade precisa ser maior que zero.
    If p_qt <= 0 Then
        Signal Sqlstate '45002' Set Message_text = 'Quantidade precisa ser > 0';
    End If;
    
    -- Combinação de cor e id válida.
    If (p_cor = 'vermelho' And p_bola_id Not Between 1 And 7)
        Or (p_cor = 'verde' And p_bola_id Not Between 8 And 14)
        Or (p_cor = 'cinza' And p_bola_id Not Between 15 And 16) Then
        Signal Sqlstate '45002' Set Message_text = 'Cor e ID não combinam';
    End If;
    
    -- Soma atual de todas as bolinhas.
    Select Coalesce(Sum(total),0) Into v_soma From cesta_bolas;
    Set v_novo_total = v_soma + p_qt;
    
    If v_novo_total <= v_capacidade Then
        -- Se o id já existir na tabela, modifica; caso contrário, insere.
        Select Count(*) Into v_existe From cesta_bolas Where bola_id = p_bola_id;
        
        If v_existe = 0 Then
            Insert Into cesta_bolas(bola_id, cor, total)
            Values(p_bola_id, p_cor, p_qt);
        Else
            Call pr_modificar_bola(p_bola_id, p_cor, p_qt);
        End If;
    Else
        -- Espaço insuficiente: insere o que couber.
        Set v_espaco = v_capacidade - v_soma;
        
        If v_espaco > 0 Then
            Insert Into cesta_bolas(bola_id, cor, total)
            Values(p_bola_id, p_cor, v_espaco);
            Select Concat('Inseridas ', v_espaco,
                ' Bolinhas; Sobraram ', (p_qt - v_espaco),
                ' Unidades.') As Aviso;
        Else
            Signal Sqlstate '45002' Set Message_text = 'Cesta cheia; nada inserido';
        End If;
    End If;
End$$

-- Procedure para modificar a quantidade de uma bola já existente ou chamar exclusão.
Create Procedure pr_modificar_bola(
    In p_bola_id Int,
    In p_cor Varchar(15),
    In p_qt Int
)
Begin
    If (Select Count(*) From cesta_bolas Where bola_id = p_bola_id) = 0 Then
        Call pr_deletar_bola(p_bola_id);
    Else
        Update cesta_bolas
        Set cor = p_cor,
            total = total + p_qt
        Where bola_id = p_bola_id;
    End If;
End$$

-- Procedure para remover o registro de uma bola.
Create Procedure pr_deletar_bola(
    In p_bola_id Int
)
Begin
    If (Select Count(*) From cesta_bolas Where bola_id = p_bola_id) = 0 Then
        Signal Sqlstate '45002' Set Message_text = 'Nenhuma bola encontrada para remoção';
    Else
        Delete From cesta_bolas Where bola_id = p_bola_id;
    End If;
End$$

Delimiter ;