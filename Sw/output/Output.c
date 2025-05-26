#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Kích thước các layer
#define IN_WIDTH 7
#define IN_HEIGHT 7
#define IN_CHANNELS 128
#define NUM_CLASSES 10

// Đọc dữ liệu từ file theo thứ tự C-W-H
void read_data_cwh(const char* filename, float* data, int size) {
    FILE* file = fopen(filename, "r");
    if (file == NULL) {
        fprintf(stderr, "Cannot open file: %s\n", filename);
        exit(1);
    }

    for (int i = 0; i < size; i++) {
        if (fscanf(file, "%f", &data[i]) != 1) {
            fprintf(stderr, "Error reading data at position %d in file %s\n", i, filename);
            fclose(file);
            exit(1);
        }
    }
    fclose(file);
}

// Global Average Pooling (xử lý đúng thứ tự C-W-H)
void global_avg_pool_cwh(const float* input, float* output) {
    for (int c = 0; c < IN_CHANNELS; c++) {
        float sum = 0.0f;
        for (int w = 0; w < IN_WIDTH; w++) {
            for (int h = 0; h < IN_HEIGHT; h++) {
                // Thứ tự: [channel][width][height]
                sum += input[c + w * IN_CHANNELS + h * IN_CHANNELS * IN_WIDTH];
            }
        }
        output[c] = sum / (IN_WIDTH * IN_HEIGHT);
    }
}

// Dense Layer
void dense_layer(const float* input, const float* weights, 
                const float* biases, float* output) {
    for (int i = 0; i < NUM_CLASSES; i++) {
        output[i] = biases[i];
        for (int j = 0; j < IN_CHANNELS; j++) {
            output[i] += input[j] * weights[i * IN_CHANNELS + j];
        }
    }
}

// Hàm in kết quả
void print_results(const char* name, const float* arr, int size, int limit) {
    printf("%s (first %d/%d elements):\n", name, limit, size);
    for (int i = 0; i < (size < limit ? size : limit); i++) {
        printf("%8.4f ", arr[i]);
        if ((i+1) % 10 == 0) printf("\n");
    }
    printf("\n\n");
}

int main() {
    // Cấp phát bộ nhớ
    float* input = malloc(IN_WIDTH * IN_HEIGHT * IN_CHANNELS * sizeof(float));
    float* pool_output = malloc(IN_CHANNELS * sizeof(float));
    float* dense_weights = malloc(IN_CHANNELS * NUM_CLASSES * sizeof(float));
    float* dense_biases = malloc(NUM_CLASSES * sizeof(float));
    float* predictions = malloc(NUM_CLASSES * sizeof(float));

    // Đọc dữ liệu từ file
    read_data_cwh("Sw/input.txt", input, IN_WIDTH * IN_HEIGHT * IN_CHANNELS);
    read_data_cwh("Sw/Dense_weight.txt", dense_weights, IN_CHANNELS * NUM_CLASSES);
    read_data_cwh("Sw/bias_dense.txt", dense_biases, NUM_CLASSES);

    // Forward pass
    global_avg_pool_cwh(input, pool_output);
    dense_layer(pool_output, dense_weights, dense_biases, predictions);

    // In kết quả debug
    print_results("Input tensor", input, IN_WIDTH * IN_HEIGHT * IN_CHANNELS, 20);
    print_results("Pool output", pool_output, IN_CHANNELS, 20);
    print_results("Predictions", predictions, NUM_CLASSES, NUM_CLASSES);

    // Tìm class có giá trị lớn nhất
    int predicted_class = 0;
    float max_value = predictions[0];
    for (int i = 1; i < NUM_CLASSES; i++) {
        if (predictions[i] > max_value) {
            max_value = predictions[i];
            predicted_class = i;
        }
    }
    printf("Predicted class: %d (raw output: %.4f)\n", predicted_class, max_value);

    // Giải phóng bộ nhớ
    free(input);
    free(pool_output);
    free(dense_weights);
    free(dense_biases);
    free(predictions);

    return 0;
}