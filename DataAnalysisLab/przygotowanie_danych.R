####_______________________________ BIBLIOTEKI ________________________________#### 

# Lista bibliotek, z których kożystamy w projkecie 



library_list <- c("ggplot2", "factoextra", "rlang", 
                  
                  "MASS", "reshape2", "corrplot",  
                  
                  "caret", "glmnet") 



# Ładowanie bibliotek, jeśli nie są załadowane 

for (library in library_list) { 
  
  if (!require(library, character.only = TRUE, quietly = TRUE)) { 
    
    if (!library %in% installed.packages()) { 
      
      install.packages(library) 
      
      library(library, character.only = TRUE)
      
    } else { 
      
      library(library, character.only = TRUE) 
      
    } 
    
  } 
  
} 







####_________________________ OPRACOWNIE DANYCH _______________________________#### 

# Wczytujemy informacje o winach białych i czerwonych  

red_wine <- read.csv("winequality-red.csv", sep = ";", header = TRUE)  

white_wine <- read.csv("winequality-white.csv", sep = ";", header = TRUE)  



# Sprawdzamy czy w naszych danych wystęują duplikaty 

duplicated(red_wine) 

red_wine[duplicated(red_wine), ] 

sum(duplicated(red_wine)) 



# Zachowujemy tylko unikalne wiersze 

red_wine <- unique(red_wine) 



# Analogicznie dla białych win 

duplicated(white_wine) 

white_wine[duplicated(white_wine), ] 

sum(duplicated(white_wine)) 

white_wine <- unique(white_wine) 



# Dodajemy target  

red_wine$type <- "red"  

white_wine$type <-"white"  



# Zestaw danych składa się ze 1359 unikalnych obserwacji dotyczących win czerwonych 

# oraz ze 3961 obserwacji dla win białych. 

# Zauważalna jest spora dysproporcja, ale liczymy, że modele sobie poradzą z klasyfikacją 

nrow(red_wine)  

nrow(white_wine)  



# Tworzymy jeden zbiór zawierający informacje zarówno o białych jak czerwonych winach  

wine <- rbind(red_wine, white_wine)  



# Zamieniamy target na zmienne binarne przypisując 1 dla win czerwonych i 0 dla win białych  

wine$type <- as.factor(ifelse(wine$type == "red", "1", "0")) 



# Sprawdzamy, czy nasz zestaw posiada braki w danych 

colSums(is.na(wine))  # Liczba braków w każdej kolumnie 



# Sprawdzamy strukturę danych, aby wiedzieć z czym pracujemy 

str(wine)  

# Wszystkie dane objaśniające są danymi ilościowymi, numerycznymi 



# Statystyczne podsumowanie danych 

summary(wine) 







####_________________________ WIZUALIZACJA DANYCH _______________________________#### 

# Histogramy dla wszystkich kolumn objaśniających,  

# aby zobaczyć jak rozkładają się wartości 

for (i in 1:(ncol(wine) - 2)) { 
  
  column_name <- colnames(wine)[i]  # Pobierz nazwę kolumny 
  
  print(ggplot(data = wine, aes_string(x = column_name)) + 
          
          geom_histogram(color = 'darkblue', fill = "cornflowerblue", bins = 30) +  
          
          labs( 
            
            title = paste("Rozkład zmiennej:", column_name), 
            
            x = column_name, 
            
            y = "Częstość" 
            
          ) + 
          
          theme_minimal()+ 
          
          theme(plot.title = element_text(hjust = 0.5))) 
  
} 



# Wykres słupkowy dla zmiennej quality (dla lepszej wizualizacji) 

barplot( 
  
  table(wine$quality),  
  
  col = "cornflowerblue", border = 'darkblue', 
  
  main = "Rozkład zmiennej: quality", 
  
  xlab = "quality",  
  
  ylab = "Częstość" 
  
) 



# Sprawdzenie korelacji między danymi 

cor_matrix <- cor(wine[, sapply(wine, is.numeric)]) 

corrplot(cor_matrix, method = "color", type = "upper", diag = FALSE, 
         
         outline = TRUE 
         
) 

# Można zauważyć, że wysoka korelacja (powyżej 0,6) występuje w dwóch przypadkach:  

# pomiędzy zmiennymi density a alcohol oraz free.sulfur.dioxide a total.sulfur.dioxide. 

# Pozostałe współczynniki korelacji nie przekraczają wartości 0,5.  

# W ramach tego projektu stosujemy m.in. regresję na składowych głównych oraz regresję grupową, 

# co minimalizuje wpływ potencjalnej współliniowości zmiennych. 







####_____________________________PODZIAŁ DANYCH________________________________#### 

# Ustawienie ziarna losowości dla powtarzalności wyników  

set.seed(4747)   



# Podział danych na zbiór treningowy i testowy w proporcji 70:30  

train_index <- createDataPartition(wine$type, p = 0.7, list = FALSE)  



#Zbiór treningowy i testowy  

train_data <- wine[train_index, ]  

test_data <- wine[-train_index, ]    



# Zamiana zbiorów treningowego i testowego na macierze numeryczne  

X_train <- model.matrix(type ~ ., train_data)[, -1]    

X_test <- model.matrix(type ~ ., test_data)[, -1]  



# Zamiana targetu na wektor numeryczny  

y_train <- as.numeric(train_data$type)  # Kolumna docelowa   

y_test <- as.numeric(test_data$type) 
