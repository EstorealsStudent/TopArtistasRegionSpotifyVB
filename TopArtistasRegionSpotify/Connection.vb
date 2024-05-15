Imports System.Data.SqlClient

Public Class Connection
    Shared cnx As New SqlConnection
    Private Shared Sub Connect()
        Try
            cnx.ConnectionString = "Data Source=localhost; Initial Catalog=TopArtistasRegion;Integrated Security=True"
            cnx.Open()
        Catch ex As Exception
            MsgBox("Error al conectar a la base de datos: " & ex.Message)
        End Try
    End Sub
    Public Shared Sub Disconect()
        Try
            If cnx.State = ConnectionState.Open Then
                cnx.Close()
            End If
        Catch ex As Exception
            MsgBox("Error al desconectar de la base de datos: " & ex.Message)
        End Try
    End Sub
    'Create a method to excecute a Selection query
    Public Shared Function SelectQuery(ByVal query As String) As DataTable
        Dim dt As New DataTable
        Try
            Connect()
            Dim cmd As New SqlCommand(query, cnx)
            Dim da As New SqlDataAdapter(cmd)
            da.Fill(dt)
        Catch ex As Exception
            MsgBox("Error al ejecutar la consulta: " & ex.Message)
        Finally
            Disconect()
        End Try
        Return dt
    End Function

    Public Shared Function ExecuteStoredProcedureReader(ByVal procedureName As String, ByVal parameters As SqlParameter()) As SqlDataReader
        Dim reader As SqlDataReader = Nothing
        Try
            Connect()
            Dim cmd As New SqlCommand(procedureName, cnx)
            cmd.CommandType = CommandType.StoredProcedure

            ' Agregar parámetros si los hay
            If parameters IsNot Nothing Then
                For Each param As SqlParameter In parameters
                    cmd.Parameters.Add(param)
                Next
            End If

            reader = cmd.ExecuteReader()

            ' Verificar si hay filas antes de cerrar la conexión
            If Not reader.HasRows Then
                ' Si no hay filas, cerrar el lector y la conexión
                reader.Close()
                Disconect()
            End If
        Catch ex As Exception
            MsgBox("Error al ejecutar el stored procedure: " & ex.Message)
            Throw
        End Try
        Return reader
    End Function

    Public Shared Function ExecuteStoredProcedure(ByVal storedProcedureName As String, ByVal parameters As SqlParameter()) As DataTable
        Dim dt As New DataTable
        Try
            Connect()
            Dim cmd As New SqlCommand()
            cmd.Connection = cnx
            cmd.CommandType = CommandType.StoredProcedure
            cmd.CommandText = storedProcedureName

            If parameters IsNot Nothing AndAlso parameters.Length > 0 Then
                For Each param As SqlParameter In parameters
                    cmd.Parameters.Add(param)
                Next
            End If

            Dim da As New SqlDataAdapter(cmd)
            da.Fill(dt)
        Catch ex As Exception
            MsgBox("Error al ejecutar el stored procedure: " & ex.Message)
        Finally
            Disconect()
        End Try
        Return dt
    End Function



End Class
