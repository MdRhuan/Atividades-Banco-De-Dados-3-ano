Delimiter $$
--  definir uma função personalizada
CREATE FUNCTION perda(Code varchar (12) )
RETURNS DECIMAL(10,2)
Deterministic
Begin

   -- declarar e inicializar variáveis
   Declare PrecoCompra Decimal;
   Declare PrecoSugerido Decimal;
   Declare MediaVenda Decimal;
   Declare LucroPrevisto Decimal;
   Declare LucroReal Decimal;
   Declare PerdaFinal Decimal;
   
   -- pegar o preco de compra e o preço sugerido
   Select BuyPrice, MSRP
   
   -- Guardar valor
   Into precoCompra, PrecoSugerido
   From Products
   Where ProductCode = Code;
   
   -- pegar a média dos PriceEach
   Select Avg(PriceEach)
   Into MediaVenda
   From OrderDetails
   Where ProductCode = Code;
   
   -- calculando o lucro previsto
   Set LucroPrevisto = PrecoSugerido / PrecoCompra;
   
   -- calculando o lucro real
   Set LucroReal = MediaVenda / PrecoCompra;

   -- a perda é a diferença dos dois
   Set PerdaFinal = lucroPrevisto - LucroReal;
   
   Return perdaFinal;
End$$
Delimiter ;