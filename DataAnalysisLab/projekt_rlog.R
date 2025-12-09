####_____________________________ Model z stepAIC __________________________####

# Ustalenie poziomów dla zmiennej celu
levels(train_data$type) <- c("white", "red")
levels(test_data$type) <- c("white", "red")

# Budowanie modelu regresji logistycznej z optymalizacją zmiennych przy pomocy kryterium AIC
model <- stepAIC(glm(type~., data = train_data, family = "binomial"), direction = "backward")

# Wyświetlanie wyników modelu
model
summary(model)


####__________________________ Ewaluacja na testowych ______________________####


# Predykcja prawdopodobieństw na danych testowych
y_pred <- predict(model, test_data, type = "response")

# Klasyfikacja na podstawie progów prawdopodobieństwa
y_pred_class <- ifelse(y_pred > 0.5, "red", "white")
y_pred_class <- factor(y_pred_class, levels = c("white", "red")) 

# Obliczanie dokładności
accuracy <- mean(y_pred_class == test_data$type) * 100
cat("Dokładność na zbiorze testowym:", accuracy, "%\n")


####___________________________ Macierz pomyłek ____________________________####


macierz_pomylek_rlog <- table(rzeczywiste = test_data$type, predykcja = y_pred_class)
macierz_pomylek_rlog

# Wizualizacja macierzy pomyłek
conf_matrix <- table(factor(test_data$type), 
                     factor(y_pred_class) )
dimnames(conf_matrix) <- list(Actual = c("0", "1"), Predicted = c("0", "1"))
fourfoldplot(conf_matrix, color = c("brown", "lightblue"), main="Macierz pomyłek\nRegresja Logistyczna")


####________________________________ Wykres ________________________________####

# Przygotowanie danych do wizualizacji
levels(test_data$type) <- as.factor(c(0,1))
levels(y_pred_class) <- as.factor(c(0,1))

dane_do_wykresow_rlog <- data.frame(
  Faktyczna = as.numeric(test_data$type) - 1,
  Prognozowane = y_pred)

dane_do_wykresow_rlog$Blad <- dane_do_wykresow_rlog$Faktyczna != y_pred_class

dane_do_wykresow_rlog$Kolor <- ifelse(
  dane_do_wykresow_rlog$Blad, 
  "Błąd w predykcji",
  paste("Dobra predykcja -", dane_do_wykresow_rlog$Faktyczna)
)

# Rysowanie wykresu z błędami predykcji
ggplot(dane_do_wykresow_rlog, aes(x = Prognozowane, y = Faktyczna)) + 
  geom_point(aes(color = Kolor, shape = Kolor, fill = Kolor), size = 2.5, alpha = 0.8, stroke = 1.2) + 
  scale_color_manual( 
    values = c("Błąd w predykcji" = "red", "Dobra predykcja - 0" = "black", "Dobra predykcja - 1" = "brown"), 
    name = "Predykcja", 
    guide = "none"  
  ) + 
  scale_fill_manual( 
    values = c("Błąd w predykcji" = "red", "Dobra predykcja - 0" = "palegoldenrod", "Dobra predykcja - 1" = "darkred"), 
    name = "Predykcja" 
  ) + 
  scale_shape_manual( 
    values = c("Błąd w predykcji" = 21, "Dobra predykcja - 0" = 21, "Dobra predykcja - 1" = 21),   
    name = "Predykcja" 
  ) + 
  guides( 
    color = "none",  
    fill = guide_legend(override.aes = list( 
      size = 4, alpha = 1, stroke = 1.2, 
      shape = c(16, 21, 16),  
      color = c("red", "black", "darkred"), 
      fill = c("red", "palegoldenrod", "darkred") 
    ))  ) + 
  stat_smooth(method = "glm", method.args = list(family = "binomial"), color = "black") + 
  labs( 
    x = "Prawdopodobieństwo klasy '1'", 
    y = "Faktyczna klasa", 
    title = "Wykres regresji logistycznej z błędami predykcji" 
  ) + 
  theme_minimal() + 
  theme( 
    legend.position = "bottom", 
    plot.title = element_text(hjust = 0.5), 
    legend.title = element_text(face = "bold") 
  ) 

