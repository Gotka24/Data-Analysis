####__________________ Wykresy z błędnymi klasyfikacjami ___________________####

# Regresja Logistyczna

# Przygotowanie danych do wizualizacji
dane_do_wykresow_rlog[dane_do_wykresow_rlog$Blad == T,]

dane_do_wykresow_rlog <- test_data
dane_do_wykresow_rlog$predykcja_rlog <- y_pred_class
dane_do_wykresow_rlog$Poprawnosc <- ifelse(dane_do_wykresow_rlog$type == y_pred_class, "Poprawna", "Błędna")
head(dane_do_wykresow_rlog)


# residual.sugar x density

ggplot(data = dane_do_wykresow_rlog, aes(x = residual.sugar , y = density)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c("peachpuff3", "darkred")) +
  geom_point(
    data = subset(dane_do_wykresow_rlog, Poprawnosc == "Błędna"),
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


# quality x alcohol

ggplot(dane_do_wykresow_rlog, aes(x = quality, y = alcohol)) +
  geom_jitter(aes(color = Poprawnosc, shape = type), width = 0.3, size = 2) +
  scale_color_manual(values = c("darkred", alpha("skyblue", 0.3))) +
  labs(x = "quality", y = "alcohol") +
  theme_minimal() +
  ggtitle(paste("Wykres punktowy zmiennej", "alcohol", "według quality dla rlog")) +
  scale_shape_discrete(name = "type") +
  scale_x_continuous(breaks = sort(unique(dane_do_wykresow_rlog$quality)))




# total.sulfur.dioxide x density

ggplot(data = dane_do_wykresow_rlog, aes(x = total.sulfur.dioxide , y = density)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 1), alpha("darkred"), 1)) +
  geom_point(
    data = subset(dane_do_wykresow_rlog, Poprawnosc == "Błędna"),
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

ggplot(data = dane_do_wykresow_rlog, aes(x = total.sulfur.dioxide , y = density)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 0.1), alpha("darkred"), 0.7)) +
  geom_point(
    data = subset(dane_do_wykresow_rlog, Poprawnosc == "Błędna"),
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

ggplot(data = dane_do_wykresow_rlog, aes(x = total.sulfur.dioxide , y = free.sulfur.dioxide)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 1), alpha("darkred"), 1)) +
  geom_point(
    data = subset(dane_do_wykresow_rlog, Poprawnosc == "Błędna"),
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

ggplot(data = dane_do_wykresow_rlog, aes(x = total.sulfur.dioxide , y = free.sulfur.dioxide)) +
  geom_point(aes(col = factor(type)), size = 3) +
  scale_color_manual(values = c(alpha("peachpuff3", 0.1), alpha("darkred"), 0.7)) +
  geom_point(
    data = subset(dane_do_wykresow_rlog, Poprawnosc == "Błędna"),
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
