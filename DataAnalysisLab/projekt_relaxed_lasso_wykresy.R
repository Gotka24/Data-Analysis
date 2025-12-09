####__________________ Wykresy z błędnymi klasyfikacjami ___________________####

# Regresja Relaxed Lasso

# Przygotowanie danych
dane_do_wykresow_rlasso <- test_data
dane_do_wykresow_rlasso$predykcja_rlog <- y_pred_class_kr
dane_do_wykresow_rlasso$Poprawnosc <- ifelse(dane_do_wykresow_rlasso$type == y_pred_class_kr, "Poprawna", "Błędna")
head(dane_do_wykresow_rlasso)


# residual.sugar x density

ggplot(data = dane_do_wykresow_rlasso, aes(x = residual.sugar , y = density)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 1), alpha("darkred"), 1)) +
  geom_point(
    data = subset(dane_do_wykresow_rlasso, Poprawnosc == "Błędna"),
    aes(x = residual.sugar, y = density),
    shape = 1, size = 5, stroke = 2, color = "red", alpha = 0.7
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5)
  ) + 
  labs( 
    color = "type", 
    title = paste( 
      "Punkty błędnie sklasyfikowane przez regresję logistyczną\n", 
      "Zmienne: ", "residual.sugar", " i ", "density" 
    ), 
    x = "residual.sugar", 
    y = "density" 
  ) 


# residual.sugar x density z przezroczystością

ggplot(data = dane_do_wykresow_rlasso, aes(x = residual.sugar , y = density)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 0.1), alpha("darkred"), 0.7)) +
  geom_point(
    data = subset(dane_do_wykresow_rlasso, Poprawnosc == "Błędna"),
    aes(x = residual.sugar, y = density),
    shape = 1, size = 5, stroke = 2, color = "red", alpha = 0.7
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5)
  ) + 
  labs( 
    color = "type", 
    title = paste( 
      "Punkty błędnie sklasyfikowane przez regresję logistyczną\n", 
      "Zmienne: ", "residual.sugar", " i ", "density" 
    ), 
    x = "residual.sugar", 
    y = "density" 
  ) 



# total.sulfur.dioxide x density

ggplot(data = dane_do_wykresow_rlasso, aes(x = total.sulfur.dioxide , y = density)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 1), alpha("darkred"), 1)) +
  geom_point(
    data = subset(dane_do_wykresow_rlasso, Poprawnosc == "Błędna"),
    aes(x = total.sulfur.dioxide, y = density),
    shape = 1, size = 5, stroke = 2, color = "red", alpha = 0.7
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5)
  ) + 
  labs( 
    color = "type", 
    title = paste( 
      "Punkty błędnie sklasyfikowane przez regresję logistyczną\n", 
      "Zmienne: ", "total.sulfur.dioxide", " i ", "density" 
    ), 
    x = "total.sulfur.dioxide", 
    y = "density" 
  ) 


# total.sulfur.dioxide x density z przezroczystością

ggplot(data = dane_do_wykresow_rlasso, aes(x = total.sulfur.dioxide , y = density)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 0.1), alpha("darkred"), 0.7)) +
  geom_point(
    data = subset(dane_do_wykresow_rlasso, Poprawnosc == "Błędna"),
    aes(x = total.sulfur.dioxide, y = density),
    shape = 1, size = 5, stroke = 2, color = "red", alpha = 0.7
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5)
  ) + 
  labs( 
    color = "type", 
    title = paste( 
      "Punkty błędnie sklasyfikowane przez regresję logistyczną\n", 
      "Zmienne: ", "total.sulfur.dioxide", " i ", "density" 
    ), 
    x = "total.sulfur.dioxide", 
    y = "density" 
  ) 




# total.sulfur.dioxide x free.sulfur.dioxide

ggplot(data = dane_do_wykresow_rlasso, aes(x = total.sulfur.dioxide , y = free.sulfur.dioxide)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 1), alpha("darkred"), 1)) +
  geom_point(
    data = subset(dane_do_wykresow_rlasso, Poprawnosc == "Błędna"),
    aes(x = total.sulfur.dioxide, y = free.sulfur.dioxide),
    shape = 1, size = 5, stroke = 2, color = "red", alpha = 0.7
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5)
  ) + 
  labs( 
    color = "type", 
    title = paste( 
      "Punkty błędnie sklasyfikowane przez regresję logistyczną\n", 
      "Zmienne: ", "total.sulfur.dioxide", " i ", "free.sulfur.dioxide" 
    ), 
    x = "total.sulfur.dioxide", 
    y = "free.sulfur.dioxide" 
  ) 



# total.sulfur.dioxide x free.sulfur.dioxide z przezroczystością

ggplot(data = dane_do_wykresow_rlasso, aes(x = total.sulfur.dioxide , y = free.sulfur.dioxide)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 0.1), alpha("darkred"), 0.7)) +
  geom_point(
    data = subset(dane_do_wykresow_rlasso, Poprawnosc == "Błędna"),
    aes(x = total.sulfur.dioxide, y = free.sulfur.dioxide),
    shape = 1, size = 5, stroke = 2, color = "red", alpha = 0.7
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5)
  ) + 
  labs( 
    color = "type", 
    title = paste( 
      "Punkty błędnie sklasyfikowane przez regresję logistyczną\n", 
      "Zmienne: ", "total.sulfur.dioxide", " i ", "free.sulfur.dioxide" 
    ), 
    x = "total.sulfur.dioxide", 
    y = "free.sulfur.dioxide" 
  ) 


# chlorides x total.sulfur.dioxide

ggplot(data = dane_do_wykresow_rlasso, aes(x = chlorides , y = total.sulfur.dioxide)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 1), alpha("darkred"), 1)) +
  geom_point(
    data = subset(dane_do_wykresow_rlasso, Poprawnosc == "Błędna"),
    aes(x = chlorides, y = total.sulfur.dioxide),
    shape = 1, size = 5, stroke = 2, color = "red", alpha = 0.7
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5)
  ) + 
  labs( 
    color = "type", 
    title = paste( 
      "Punkty błędnie sklasyfikowane przez regresję logistyczną\n", 
      "Zmienne: ", "chlorides", " i ", "total.sulfur.dioxide" 
    ), 
    x = "chlorides", 
    y = "total.sulfur.dioxide" 
  ) 



# chlorides x total.sulfur.dioxide z przezroczystością

ggplot(data = dane_do_wykresow_rlasso, aes(x = chlorides , y = total.sulfur.dioxide)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 0.1), alpha("darkred"), 0.7)) +
  geom_point(
    data = subset(dane_do_wykresow_rlasso, Poprawnosc == "Błędna"),
    aes(x = chlorides, y = total.sulfur.dioxide),
    shape = 1, size = 5, stroke = 2, color = "red", alpha = 0.7
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5)
  ) + 
  labs( 
    color = "type", 
    title = paste( 
      "Punkty błędnie sklasyfikowane przez regresję logistyczną\n", 
      "Zmienne: ", "chlorides", " i ", "total.sulfur.dioxide" 
    ), 
    x = "chlorides", 
    y = "total.sulfur.dioxide" 
  ) 


