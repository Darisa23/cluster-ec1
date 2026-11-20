#include <mpi.h>
#include <stdio.h>
#include <unistd.h>
#include <netdb.h>
#include <time.h>
#include <arpa/inet.h>

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    char host[256];
    gethostname(host, sizeof(host));

    char ip[64] = "desconocida";
    struct hostent *he = gethostbyname(host);
    if (he) inet_ntop(AF_INET, he->h_addr_list[0], ip, sizeof(ip));

    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    struct tm t;
    localtime_r(&ts.tv_sec, &t);

    FILE *f = fopen("/home/ec1/shared/resultados.txt", "a");
    if (f) {
        fprintf(f, "rank %d/%d | host=%s | ip=%s | %04d-%02d-%02d %02d:%02d:%02d.%06ld\n",
                rank, size, host, ip,
                t.tm_year + 1900, t.tm_mon + 1, t.tm_mday,
                t.tm_hour, t.tm_min, t.tm_sec, ts.tv_nsec / 1000);
        fclose(f);
    }

    MPI_Finalize();
    return 0;
}
