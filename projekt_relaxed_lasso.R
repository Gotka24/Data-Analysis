####________________________ Model z kroswalidacją _________________________####

# Tworzenie modelu Relaxed Lasso z kroswalidacją
relaxed_lasso_kr <- cv.glmnet(X_train, y_train, family = 'binomial',
                           relax = T, nfolds = 10)

# Wyświetlanie wyników kroswalidacji
relaxed_lasso_kr

# Współczynniki modelu dla lambda i gamma 1.se
coef(relaxed_lasso_kr, s = "lambda.1se", gamma = "gamma.1se")

# Predykcja na zbiorze testowym
y_pred_kr <- predict(relaxed_lasso_kr, newx = X_test, type = "response", s = "lambda.1se", gamma = "gamma.1se")
y_pred_class_kr <- ifelse(y_pred_kr > 0.5, 1, 0)

# Obliczenie dokładności modelu
accuracy_kr<- mean(y_pred_class_kr == y_test-1)*100
cat("Dokładność:", accuracy_kr, "%\n")

# Tworzenie macierzy pomyłek
macierz_pomylek_chill_kr <- table(rzeczywiste = test_data$type, predykcja = y_pred_class_kr)
macierz_pomylek_chill_kr

# Wizualizacja macierz pomyłek
conf_matrix <- table(factor(test_data$type), 
                     factor(y_pred_class_kr) )
dimnames(conf_matrix) <- list(Actual = c("0", "1"), Predicted = c("0", "1"))
fourfoldplot(conf_matrix, color = c("brown", "lightblue"), main="Macierz pomyłek\nRelaxed Lasso")

####________________________________ Wykres ________________________________####

# Konwersja poziomów zmiennej 'type' na wartości numeryczne
levels(test_data$type) <- as.factor(c(0,1))
levels(y_pred_class_kr) <- as.factor(c(0,1))

# Przygotowanie danych do wizualizacji
dane_do_wykresow_rlasso <- data.frame(
  Faktyczna = as.numeric(test_data$type) - 1,
  Prognozowane = y_pred_kr[,1])

dane_do_wykresow_rlasso$Blad <- dane_do_wykresow_rlasso$Faktyczna != y_pred_class_kr

dane_do_wykresow_rlasso$Kolor <- ifelse(
  dane_do_wykresow_rlasso$Blad, 
  "Błąd w predykcji",
  paste("Dobra predykcja -", dane_do_wykresow_rlasso$Faktyczna)
)

# Rysowanie wykresu regresji z oznaczeniem błędnych predykcji
ggplot(dane_do_wykresow_rlasso, aes(x = Prognozowane, y = Faktyczna)) + 
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
    title = "Wykres Relaxed Lasso\nna regresji logistycznej z błędami predykcji" 
  ) + 
  theme_minimal() + 
  theme( 
    legend.position = "bottom", 
    plot.title = element_text(hjust = 0.5), 
    legend.title = element_text(face = "bold") 
  ) 

