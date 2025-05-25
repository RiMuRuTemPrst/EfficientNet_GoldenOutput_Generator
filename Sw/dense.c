#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

// Kích thước các layer
#define IN_WIDTH 7
#define IN_HEIGHT 7
#define IN_CHANNELS 128
#define NUM_CLASSES 10

// Khởi tạo dữ liệu ngẫu nhiên
void init_random(float* arr, int size, float scale) {
    for (int i = 0; i < size; i++) {
        arr[i] = scale * (2.0f * rand() / RAND_MAX - 1.0f); // [-scale, scale]
    }
}

// Global Average Pooling: 7x7x128 -> 1x1x128
void global_avg_pool(const float* input, float* output) {
    float scale = 1.0f / (IN_WIDTH * IN_HEIGHT);
    
    for (int c = 0; c < IN_CHANNELS; c++) {
        float sum = 0.0f;
        for (int h = 0; h < IN_HEIGHT; h++) {
            for (int w = 0; w < IN_WIDTH; w++) {
                sum += input[c * IN_WIDTH * IN_HEIGHT + h * IN_WIDTH + w];
            }
        }
        output[c] = sum * scale;
    }
}

// Dense Layer: 128 -> 10
void dense_layer(const float* input, const float* weights, 
                const float* biases, float* output) {
    for (int i = 0; i < NUM_CLASSES; i++) {
        output[i] = biases[i];
        for (int j = 0; j < IN_CHANNELS; j++) {
            output[i] += input[j] * weights[i * IN_CHANNELS + j];
        }
    }
}

// Hàm softmax
void softmax(float* input, int size) {
    float max = input[0];
    float sum = 0.0f;
    
    // Tìm giá trị max để tránh tràn số
    for (int i = 1; i < size; i++) {
        if (input[i] > max) max = input[i];
    }
    
    // Tính exp và tổng
    for (int i = 0; i < size; i++) {
        input[i] = expf(input[i] - max);
        sum += input[i];
    }
    
    // Chuẩn hóa
    for (int i = 0; i < size; i++) {
        input[i] /= sum;
    }
}

// In kết quả
void print_results(const char* name, const float* arr, int size) {
    printf("%s:\n", name);
    for (int i = 0; i < size; i++) {
        printf("%5.2f ", arr[i]);
    }
    printf("\n\n");
}

int main() {
    srand(time(NULL));
    
    // Cấp phát bộ nhớ
    float* input = malloc(IN_WIDTH * IN_HEIGHT * IN_CHANNELS * sizeof(float));
    float* pool_output = malloc(IN_CHANNELS * sizeof(float));
    float* dense_weights = malloc(IN_CHANNELS * NUM_CLASSES * sizeof(float));
    float* dense_biases = malloc(NUM_CLASSES * sizeof(float));
    float* predictions = malloc(NUM_CLASSES * sizeof(float));
    
    // Khởi tạo dữ liệu
    init_random(input, IN_WIDTH * IN_HEIGHT * IN_CHANNELS, 1.0f);
    init_random(dense_weights, IN_CHANNELS * NUM_CLASSES, 0.1f);
    init_random(dense_biases, NUM_CLASSES, 0.01f);
    
    // Forward pass
    global_avg_pool(input, pool_output);
    dense_layer(pool_output, dense_weights, dense_biases, predictions);
    softmax(predictions, NUM_CLASSES);
    
    // In kết quả debug
    print_results("Input (first 10 channels)", input, 10);
    print_results("Pool output (first 10)", pool_output, 10);
    print_results("Predictions", predictions, NUM_CLASSES);
    
    // Tìm class có xác suất cao nhất
    int predicted_class = 0;
    float max_prob = predictions[0];
    for (int i = 1; i < NUM_CLASSES; i++) {
        if (predictions[i] > max_prob) {
            max_prob = predictions[i];
            predicted_class = i;
        }
    }
    printf("Predicted class: %d (%.2f%%)\n", predicted_class, max_prob*100);
    
    // Giải phóng bộ nhớ
    free(input);
    free(pool_output);
    free(dense_weights);
    free(dense_biases);
    free(predictions);
    
    return 0;
}