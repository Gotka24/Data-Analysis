####_________________________________ PCA _____________________________________####

# Przeprowadzenie PCA na zbiorze treningowym (pomijamy zmienną docelową)
pca <- princomp(x = train_data[,-ncol(train_data)], cor = TRUE)

# Wyświetlenie podsumowania wyników PCA
summary(pca)

# Wyciągnięcie macierzy ładunków składowych głównych
# Macierz ładunków pokazuje, jak każda zmienna wejściowa wpływa na poszczególne składowe główne
zmiana_bazy <- pca$loadings[]
print(zmiana_bazy)


# Wizualizacja wpływu zmiennych na składowe główne

# Przekształcenie macierzy ładunków do formatu "długiego" dla wizualizacji
loadings_long <- melt(zmiana_bazy)
colnames(loadings_long) <- c("Feature", "Component", "Value")

ggplot(loadings_long, aes(x = Component, y = Feature, fill = Value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "white", high = "brown", midpoint = 0) +
  geom_text(aes(label = round(Value, 2)), color = "black", size = 3) +  # Dodanie wartości na polach
  theme_minimal() +
  labs(
    title = "Wpływ cech na składowe główne (macierz ładunków)",
    x = "Składowa główna",
    y = "Cecha"
  ) +
  theme(plot.title = element_text(hjust = 0.5))



####___________________________ PRZEKSZTAŁCENIE DANYCH ___________________________####
# Przekształcenie zbioru treningowego na współrzędne składowych głównych
train_scores <- as.data.frame(pca$scores)

# Zapisanie parametrów standaryzacji (średnich i odchyleń) ze zbioru treningowego
# Parametry te będą potrzebne do przekształcenia zbioru testowego w ten sam sposób
srednie <- pca$center
odchylenia <- pca$scale

# Ręczna standaryzacja zbioru treningowego
# Współrzędne składowych głównych są wynikiem mnożenia danych przez macierz ładunków
train_data_manual <- scale(train_data[,-ncol(train_data)], center = srednie, scale = odchylenia)
train_scores_manual <- as.data.frame((train_data_manual) %*% zmiana_bazy)

# Porównanie wyników ręcznej transformacji i wyników z princomp()
# Sprawdzamy maksymalny błąd między dwoma metodami - powinien wynosić 0
error <- max(abs(train_scores_manual - train_scores))
error # Błąd wynosi 0, co oznacza, że przekształcenie zostało przeprowadzone poprawnie.

# Standaryzacja zbioru testowego na podstawie parametrów z danych treningowych
# Przekształcenie zbioru testowego na współrzędne składowych głównych
test_data_manual <- scale(test_data[,-ncol(test_data)], center = srednie, scale = odchylenia)
test_scores <- as.data.frame(test_data_manual %*% zmiana_bazy)

# Dodanie zmiennej celu do danych testowych i treningowych
test_scores$type <- test_data[, ncol(test_data)] 
train_scores$type <- train_data[, ncol(train_data)] 



####________________WYBÓR SKŁADOWYCH GŁÓWNYCH DO REGRESJI LOGISTYCZNEJ_________________####
#WYJAŚNIONA WARIANCJA

# Procent wyjaśnionej wariancji przez każdą składową główną
explained_variance <- pca$sdev^2 / sum(pca$sdev^2)

# Wykres skumulowanej wyjaśnionej wariancji
qplot(seq_along(explained_variance), cumsum(explained_variance), geom = "line") +
  geom_point() +
  theme_minimal() +
  labs(
    title = "Wariancja wyjaśniona przez składowe główne",
    x = "Składowa głowna",
    y = "Skumulowana wyjaśniona wariancja"
  ) +
  geom_hline(yintercept = 0.9, linetype = "dashed", color = "brown") + # Linia dla 90% wariancji
  theme(plot.title = element_text(hjust = 0.5))

# 8 składowych wyjaśnia ponad 90% wariancji
components_explained_var <- c(1:8)
components_explained_var_names <- paste0("Comp.", components_explained_var)


# WYKRES OSYPISKA + KRYTERIUM KAISERA
# Wykres osypiska (Scree Plot) - identyfikacja punktu załamania
# Punkt załamania wskazuje, po ilu składowych dalsze dodawanie niewiele wnosi do wyjaśnionej wariancji
plot(pca, type = "lines", main = "Scree Plot") 
# Wydaje się, że punktem załamania jest comp.4

# Dodanie poziomej linii pomocniczej na poziomie 1 (Kryterium Kaisera)
abline(h = 1, col = "brown", lty = 2)  

# Zgodnie z Kryterium Kaisera wybieramy składowe, których wartości własne są większe niż 1
components_kaiser <- which((pca$sdev)^2 > 1) 
components_kaiser_names <- paste0("Comp.", components_kaiser)


# AIC
# Tworzenie początkowego modelu z wszystkimi komponentami PCA
full_model <- glm(type ~ ., data = train_scores, family = "binomial")

# Selekcja zmiennych przy użyciu stepAIC (automatyczna selekcja optymalnego modelu)
# StepAIC wybiera zestaw komponentów na podstawie kryterium informacyjnego AIC
stepwise_model <- stepAIC(full_model, direction = "both", trace = TRUE)
summary(stepwise_model)

# Komponenty wybrane na podstawie AIC
components_aic <- c(1, 3, 4, 5, 8, 9, 10, 11, 12)
components_aic_names <- paste0("Comp.", components_aic)

# Tworzenie listy zestawów komponentów do porównania modeli
components <- list(components_explained_var_names, components_kaiser_names, components_aic_names)
criteria_names <- c("Explained Variance", "Scree plot + Kaiser Criterion", "AIC")



####________ TRENOWANIE MOEDLI REGRESJI LOGISTYCZNEJ NA SKŁADOWYCH GŁÓWNYCH_________##### 

# Modele z wybranymi komponentami przez powyższe kryteria komponentach sprawdzamy w
# nastęujący sposób: dzielimy dane treningowe na trzy części. 
# Każdy model testujemy na jednej z trzech części, a pozostałe dwie stają się zbiorem do treningu.
# Celem tego procesu jest wybór modelu, który najlepiej dopasowuje się do danych treningowych.

# Funkcja do trenowania modelu, przewidywania i obliczania dokładności
train_eval <- function(train_data, test_data, components, criterion_name) {
  # Trenowanie modelu
  model <- glm(
    formula = type ~ .,  
    data = train_data[, c(components, "type")],  
    family = "binomial"
  )
  
  # Przewidywanie
  predictions <- predict(model, newdata = test_data[, c(components, "type")], type = "response")
  predicted_classes <- ifelse(predictions > 0.5, 1, 0)
  
  # Tworzenie macierzy pomyłek
  conf_table <- table(
    Actual = factor(test_data$type, levels = c(0, 1)), 
    Predicted = factor(predicted_classes, levels = c(0, 1))
  )
  
  # Obliczanie dokładności
  accuracy <- sum(diag(conf_table)) / sum(conf_table)
  
  # Wyświetlenie wyników
  cat("\nMacierz pomyłek dla", criterion_name, ":\n")
  print(conf_table)
  cat("Dokładność dla", criterion_name, ":", accuracy, "\n")
  
  return(accuracy)
}

# Proporcjonalny podział danych treningowych na trzy części
folds <- createFolds(train_scores$type, k = 3, list = TRUE)

# Przygotowanie danych
data_splits <- list(
  exp_var = list(
    test = train_scores[folds[[1]], , drop = FALSE],
    train = train_scores[c(folds[[2]], folds[[3]]), , drop = FALSE],
    components = components_explained_var_names
  ),
  kaiser = list(
    test = train_scores[folds[[2]], , drop = FALSE],
    train = train_scores[c(folds[[1]], folds[[3]]), , drop = FALSE],
    components = components_kaiser_names
  ),
  aic = list(
    test = train_scores[folds[[3]], , drop = FALSE],
    train = train_scores[c(folds[[1]], folds[[2]]), , drop = FALSE],
    components = components_aic_names
  )
)

# Wywołanie funkcji dla każdego kryterium
accuracy_results <- lapply(names(data_splits), function(criterion) {
  split <- data_splits[[criterion]]
  train_eval(split$train, split$test, split$components, criterion)
})

# Wyświetlenie wyników
accuracy_results <- setNames(accuracy_results, names(data_splits))
print(accuracy_results)

# Model oparty na kryterium AIC osiągnął najwyższą dokładność, wyprzedzając model 
# z wyjaśnioną wariancją o 0.0056 oraz model Kaisera o 0.0105. AIC wykorzystuje 
# 9 komponentów, wariancja 8, a Kaiser tylko 4. Różnice w dokładności są niewielkie, 
# co przemawia za wyborem prostszego modelu z mniejszą liczbą komponentów.


# Tworzenie wybranego modelu
best_model <-glm(
  formula = type ~ .,  
  data = train_scores[, c(components_kaiser_names, "type")],  
  family = "binomial"
)
summary(best_model)

####_______________________________ TESTOWANIE MODELU_________________________________####

# Przewidywanie
predictions <- predict(best_model, newdata = test_scores[, c(components_kaiser_names, "type")], type = "response")
predicted_classes <- ifelse(predictions > 0.5, 1, 0)

# Tworzenie macierzy pomyłek
conf_table <- table(
  Actual = factor(test_scores$type, levels = c(0, 1)), 
  Predicted = factor(predicted_classes, levels = c(0, 1))
)
accuracy <- sum(diag(conf_table)) / sum(conf_table)
accuracy

####___________________________________ WYKRESY ______________________________________####

# Wyświetlanie macierzy pomyłek
fourfoldplot(
  conf_table, 
  color = c("brown", "lightblue"), 
  main = paste("Macierz pomyłek\nRegresja logistyczna na PCA")
)



# Przygotowanie danych do wykresów
dane_do_wykresow <- data.frame(
  Faktyczna = as.numeric(test_scores$type) -1,  # Faktyczna klasa
  Prognozowane = predictions  # Prawdopodobieństwo klasy '1'
)

# Dodanie kolumny wskazującej błędne predykcje 
dane_do_wykresow$Blad <- dane_do_wykresow$Faktyczna != ifelse(dane_do_wykresow$Prognozowane > 0.5, 1, 0)

# Dodanie kolumny z opisami dla kolorów na wykresie 
dane_do_wykresow$Kolor <- ifelse(
  dane_do_wykresow$Blad,
  "Błąd w predykcji",
  paste("Dobra predykcja -", dane_do_wykresow$Faktyczna)
)


# Wykres błędnych klasyfikacji modelu
ggplot(dane_do_wykresow, aes(x = Prognozowane, y = Faktyczna)) +
  geom_point(aes(color = Kolor, shape = Kolor, fill = Kolor), size = 2.5, alpha = 0.8, stroke = 1.2) +  
  scale_color_manual(
    values = c("Błąd w predykcji" = "red", "Dobra predykcja - 0" = "black", "Dobra predykcja - 1" = "brown"),
    name = "Predykcja",
    guide = "none"  
  ) +
  scale_fill_manual(
    values = c("Błąd w predykcji" = "red", "Dobra predykcja - 0" = "peachpuff3", "Dobra predykcja - 1" = "darkred"), 
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
        fill = c("red", "peachpuff3", "darkred")
      ))  ) +
  stat_smooth(method = "glm", method.args = list(family = "binomial"), color = "black") +
  labs(
    x = "Prawdopodobieństwo klasy '1'",
    y = "Faktyczna klasa",
    title = "Wykres regresji logistycznej z PCA z błędami predykcji"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5),
    legend.title = element_text(face = "bold")
  )


dane_do_wykresow <- test_scores[, c(components_kaiser_names, "type")]
dane_do_wykresow$predykcja <- predicted_classes
dane_do_wykresow$poprawnosc <- ifelse(dane_do_wykresow$type == predicted_classes, "Poprawna", "Błędna")

# Lista kolumn do analizy
columns <- as.character(setdiff(colnames(dane_do_wykresow), c("type", "predykcja", "poprawnosc")))

for (i in seq_along(columns)) { 
  for (j in seq_along(columns)) { 
    if (i >= j) next 
    
    x_col <- columns[i] 
    y_col <- columns[j] 
    
    plot <- ggplot(data = dane_do_wykresow, aes_string(x = x_col, y = y_col)) + 
      geom_point(aes(col = factor(type)), size = 3) + 
      scale_color_manual(values = c(alpha("peachpuff3", 0.3), alpha("darkred", 0.7))) + 
      geom_point( 
        data = subset(dane_do_wykresow, poprawnosc == "Błędna"), 
        aes_string(x = x_col, y = y_col), 
        shape = 1, size = 5, stroke = 2, color = "red", alpha = 0.7 
      ) + 
      theme( 
        legend.position = "bottom", 
        plot.title = element_text(hjust = 0.5) 
      ) + 
      labs( 
        color = "type", 
        title = paste( 
          "Punkty błędnie sklasyfikowane przez regresję logistyczną z PCA\n", 
          "Kolumny: ", x_col, " i ", y_col 
        ), 
        x = x_col, 
        y = y_col 
      )     
    print(plot)  
  } 
}
