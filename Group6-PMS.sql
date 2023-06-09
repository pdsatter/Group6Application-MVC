PGDMP                         {        
   Group6-PMS %   12.14 (Ubuntu 12.14-0ubuntu0.20.04.1)    15.2 T    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16389 
   Group6-PMS    DATABASE     t   CREATE DATABASE "Group6-PMS" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
    DROP DATABASE "Group6-PMS";
                postgres    false                        2615    2200    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                postgres    false            �            1255    16969    Update_Project_Cost()    FUNCTION     k  CREATE FUNCTION public."Update_Project_Cost"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE "Project"
        SET "Cost" = "Cost" + NEW."HoursWorked" * "Employee"."Wage"
        FROM "Employee"
        WHERE "Project"."ID" = NEW."ProjectID" AND "Employee"."ID" = NEW."WorkerID";
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE "Project"
        SET "Cost" = "Cost" - OLD."HoursWorked" * "Employee"."Wage" + NEW."HoursWorked" * "Employee"."Wage"
        FROM "Employee"
        WHERE "Project"."ID" = NEW."ProjectID" AND "Employee"."ID" = NEW."WorkerID";
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE "Project"
        SET "Cost" = "Cost" - OLD."HoursWorked" * "Employee"."Wage"
        FROM "Employee"
        WHERE "Project"."ID" = OLD."ProjectID" AND "Employee"."ID" = OLD."WorkerID";
    END IF;
    RETURN NULL;
END;$$;
 .   DROP FUNCTION public."Update_Project_Cost"();
       public          dhillebrand    false    7            �            1255    16898    employeechanges()    FUNCTION     �   CREATE FUNCTION public.employeechanges() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE "Department"
	SET "Number_of_Employees" = (SELECT COUNT (*) FROM "Employee" WHERE "Employee"."DepartmentID" = "Department"."ID");
	RETURN NEW;
END;	
$$;
 (   DROP FUNCTION public.employeechanges();
       public          dhillebrand    false    7            �            1255    16903    update_checkpoint_status()    FUNCTION     �  CREATE FUNCTION public.update_checkpoint_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    IF New."Status" = 'Complete' THEN
        IF (SELECT COUNT(*) = 0 FROM "Task" WHERE "CheckpointID" = New."CheckpointID" AND "Status" != 'Complete') THEN
            UPDATE "Checkpoint" SET "Status" = 'Complete' WHERE "ID" = NEW."CheckpointID";
        END IF;
    ELSE
        UPDATE "Checkpoint" SET "Status" = 'Incomplete' WHERE "ID" = NEW."CheckpointID";
    END IF;
    RETURN NEW;
END;$$;
 1   DROP FUNCTION public.update_checkpoint_status();
       public          dhillebrand    false    7            �            1255    16979    update_project_cost()    FUNCTION     �   CREATE FUNCTION public.update_project_cost() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW."Cost" > NEW."Budget" THEN
    NEW."OverBudget" := TRUE;
  ELSE
    NEW."OverBudget" := FALSE;
  END IF;
  RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.update_project_cost();
       public          dhillebrand    false    7            �            1259    16728    Authentication    TABLE     �   CREATE TABLE public."Authentication" (
    "Username" character varying(64) NOT NULL,
    "Password" character varying(64) NOT NULL,
    "Role" character varying(64),
    "EmployeeID" integer
);
 $   DROP TABLE public."Authentication";
       public         heap 	   psatt2002    false    7            �            1259    16734 
   Checkpoint    TABLE     U  CREATE TABLE public."Checkpoint" (
    "Name" character varying(128),
    "Description" character varying(1024),
    "StartDate" date,
    "DueDate" date,
    "ProjectID" integer NOT NULL,
    "ID" integer NOT NULL,
    "Status" character varying(10) DEFAULT 'Incomplete'::character varying,
    CONSTRAINT "Checkpoint_Status_check" CHECK ((("Status")::text = ANY ((ARRAY['Complete'::character varying, 'Incomplete'::character varying])::text[]))),
    CONSTRAINT statusrequired CHECK ((("Status")::text = ANY ((ARRAY['Incomplete'::character varying, 'Complete'::character varying])::text[])))
);
     DROP TABLE public."Checkpoint";
       public         heap    dion    false    7            �           0    0    TABLE "Checkpoint"    COMMENT     =   COMMENT ON TABLE public."Checkpoint" IS 'checkpoint entity';
          public          dion    false    203            �            1259    16908    Checkpoint_ID_seq    SEQUENCE     �   ALTER TABLE public."Checkpoint" ALTER COLUMN "ID" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Checkpoint_ID_seq"
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          dion    false    7    203            �            1259    16740    Client    TABLE     �   CREATE TABLE public."Client" (
    "CompanyName" character varying(128) NOT NULL,
    "Description" character varying(1024),
    "Email" character varying(256),
    "Phone Number" integer,
    "ID" integer NOT NULL,
    "ProjectID" integer
);
    DROP TABLE public."Client";
       public         heap    mz    false    7            �            1259    16746 
   Department    TABLE     �   CREATE TABLE public."Department" (
    "ID" integer NOT NULL,
    "Name" character varying(256) NOT NULL,
    "Number_of_Employees" integer DEFAULT 0,
    "SupervisorID" integer,
    deleted boolean DEFAULT false NOT NULL
);
     DROP TABLE public."Department";
       public         heap 	   psatt2002    false    7            �            1259    16751    Department_ID_seq    SEQUENCE     �   ALTER TABLE public."Department" ALTER COLUMN "ID" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Department_ID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public       	   psatt2002    false    205    7            �            1259    16753    Employee    TABLE     �  CREATE TABLE public."Employee" (
    "ID" integer NOT NULL,
    "Email" character varying(256),
    "Address" character varying(512),
    "Title" character varying(256),
    "Wage" double precision DEFAULT 0,
    "DepartmentID" integer,
    "SupervisorID" integer,
    "FirstName" character varying(256) NOT NULL,
    "LastName" character varying(256) NOT NULL,
    "PhoneNumber" character varying(24),
    "StartDate" character varying(64),
    deleted boolean DEFAULT false NOT NULL
);
    DROP TABLE public."Employee";
       public         heap    dion    false    7            �           0    0    TABLE "Employee"    COMMENT     9   COMMENT ON TABLE public."Employee" IS 'Employee entity';
          public          dion    false    207            �            1259    16760    Employee_ID_seq    SEQUENCE     �   ALTER TABLE public."Employee" ALTER COLUMN "ID" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Employee_ID_seq"
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          dion    false    7    207            �            1259    16769 	   Outsource    TABLE     �   CREATE TABLE public."Outsource" (
    "Name" character varying(128) NOT NULL,
    "Oursource ID" integer NOT NULL,
    "Email" character varying(256) NOT NULL,
    "Phone Number" integer,
    "Job" character varying(256) NOT NULL,
    "TaskID" integer
);
    DROP TABLE public."Outsource";
       public         heap    nico    false    7            �            1259    16775    Project    TABLE     �  CREATE TABLE public."Project" (
    "ID" integer NOT NULL,
    "Name" character varying(256) NOT NULL,
    "Hours" double precision,
    "Cost" double precision,
    "ClientID" integer,
    "Budget" double precision,
    "DepartmentID" integer,
    "SupervisorID" integer,
    "Status" character varying(256) DEFAULT 'Incomplete'::character varying,
    "Description" character varying(256),
    "StartDate" date,
    "EndDate" date,
    deleted boolean DEFAULT false NOT NULL,
    "OverBudget" boolean DEFAULT false,
    CONSTRAINT statusrequiredproject CHECK ((("Status")::text = ANY ((ARRAY['Complete'::character varying, 'Incomplete'::character varying])::text[])))
);
    DROP TABLE public."Project";
       public         heap    dion    false    7            �           0    0    TABLE "Project"    COMMENT     7   COMMENT ON TABLE public."Project" IS 'project entity';
          public          dion    false    210            �           0    0    COLUMN "Project"."ID"    COMMENT     9   COMMENT ON COLUMN public."Project"."ID" IS 'project ID';
          public          dion    false    210            �           0    0    COLUMN "Project"."Name"    COMMENT     @   COMMENT ON COLUMN public."Project"."Name" IS 'name of project';
          public          dion    false    210            �           0    0    COLUMN "Project"."Hours"    COMMENT     T   COMMENT ON COLUMN public."Project"."Hours" IS 'Cumulative hours worked on project';
          public          dion    false    210            �           0    0    COLUMN "Project"."Cost"    COMMENT     F   COMMENT ON COLUMN public."Project"."Cost" IS 'total cost of project';
          public          dion    false    210            �           0    0    COLUMN "Project"."ClientID"    COMMENT     _   COMMENT ON COLUMN public."Project"."ClientID" IS 'id of the client project is being made for';
          public          dion    false    210            �           0    0    COLUMN "Project"."Budget"    COMMENT     L   COMMENT ON COLUMN public."Project"."Budget" IS 'cost limit of the project';
          public          dion    false    210            �           0    0    COLUMN "Project"."DepartmentID"    COMMENT     h   COMMENT ON COLUMN public."Project"."DepartmentID" IS 'id department controlling project (or made for)';
          public          dion    false    210            �            1259    16905    Project_ID_seq    SEQUENCE     �   ALTER TABLE public."Project" ALTER COLUMN "ID" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Project_ID_seq"
    START WITH 1
    INCREMENT BY 4
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          dion    false    210    7            �            1259    16781    Task    TABLE     �  CREATE TABLE public."Task" (
    "Start" date,
    "Due" date,
    "CheckpointID" integer,
    "Assignee" integer,
    "ID" integer NOT NULL,
    "Name" character varying(128),
    "Status" character varying(128) DEFAULT 'Incomplete'::character varying,
    "Description" character varying(2048),
    deleted boolean DEFAULT false NOT NULL,
    CONSTRAINT statusconstraint CHECK ((("Status")::text = ANY ((ARRAY['Incomplete'::character varying, 'Complete'::character varying])::text[]))),
    CONSTRAINT statusrequiredtask CHECK ((("Status")::text = ANY ((ARRAY['Incomplete'::character varying, 'Complete'::character varying])::text[])))
);
    DROP TABLE public."Task";
       public         heap    dhillebrand    false    7            �           0    0    TABLE "Task"    COMMENT     3   COMMENT ON TABLE public."Task" IS 'project tasks';
          public          dhillebrand    false    211            �           0    0    COLUMN "Task"."Start"    COMMENT     9   COMMENT ON COLUMN public."Task"."Start" IS 'start date';
          public          dhillebrand    false    211            �           0    0    COLUMN "Task"."Due"    COMMENT     6   COMMENT ON COLUMN public."Task"."Due" IS 'Due date ';
          public          dhillebrand    false    211            �            1259    16787    Task_ID_seq    SEQUENCE     �   ALTER TABLE public."Task" ALTER COLUMN "ID" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Task_ID_seq"
    START WITH 3
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          dhillebrand    false    211    7            �            1259    16789 	   Timesheet    TABLE     �   CREATE TABLE public."Timesheet" (
    "Date" date NOT NULL,
    "HoursWorked" double precision NOT NULL,
    "EntryID" integer NOT NULL,
    "ProjectID" integer NOT NULL,
    "WorkerID" integer NOT NULL,
    deleted boolean DEFAULT false NOT NULL
);
    DROP TABLE public."Timesheet";
       public         heap    nico    false    7            �            1259    16910    Timesheet Entry_EntryID_seq    SEQUENCE     �   ALTER TABLE public."Timesheet" ALTER COLUMN "EntryID" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Timesheet Entry_EntryID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          nico    false    213    7            �            1259    16792    __EFMigrationsHistory    TABLE     �   CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);
 +   DROP TABLE public."__EFMigrationsHistory";
       public         heap    postgres    false    7            �          0    16728    Authentication 
   TABLE DATA                 public       	   psatt2002    false    202   �l       �          0    16734 
   Checkpoint 
   TABLE DATA                 public          dion    false    203   hm       �          0    16740    Client 
   TABLE DATA                 public          mz    false    204   �o       �          0    16746 
   Department 
   TABLE DATA                 public       	   psatt2002    false    205   �o       �          0    16753    Employee 
   TABLE DATA                 public          dion    false    207   �q       �          0    16769 	   Outsource 
   TABLE DATA                 public          nico    false    209   �s       �          0    16775    Project 
   TABLE DATA                 public          dion    false    210   �s       �          0    16781    Task 
   TABLE DATA                 public          dhillebrand    false    211   {v       �          0    16789 	   Timesheet 
   TABLE DATA                 public          nico    false    213   �x       �          0    16792    __EFMigrationsHistory 
   TABLE DATA                 public          postgres    false    214   �y       �           0    0    Checkpoint_ID_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public."Checkpoint_ID_seq"', 16, true);
          public          dion    false    216            �           0    0    Department_ID_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public."Department_ID_seq"', 31, true);
          public       	   psatt2002    false    206            �           0    0    Employee_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Employee_ID_seq"', 36, true);
          public          dion    false    208            �           0    0    Project_ID_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public."Project_ID_seq"', 141, true);
          public          dion    false    215                        0    0    Task_ID_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public."Task_ID_seq"', 20, true);
          public          dhillebrand    false    212                       0    0    Timesheet Entry_EntryID_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public."Timesheet Entry_EntryID_seq"', 26, true);
          public          nico    false    217            5           2606    16922 "   Authentication Authentication_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public."Authentication"
    ADD CONSTRAINT "Authentication_pkey" PRIMARY KEY ("Username");
 P   ALTER TABLE ONLY public."Authentication" DROP CONSTRAINT "Authentication_pkey";
       public         	   psatt2002    false    202            7           2606    16798    Checkpoint Checkpoint_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Checkpoint"
    ADD CONSTRAINT "Checkpoint_pkey" PRIMARY KEY ("ID");
 H   ALTER TABLE ONLY public."Checkpoint" DROP CONSTRAINT "Checkpoint_pkey";
       public            dion    false    203            9           2606    16800    Client Client ID 
   CONSTRAINT     T   ALTER TABLE ONLY public."Client"
    ADD CONSTRAINT "Client ID" PRIMARY KEY ("ID");
 >   ALTER TABLE ONLY public."Client" DROP CONSTRAINT "Client ID";
       public            mz    false    204            ;           2606    16802    Department Department_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Department"
    ADD CONSTRAINT "Department_pkey" PRIMARY KEY ("ID");
 H   ALTER TABLE ONLY public."Department" DROP CONSTRAINT "Department_pkey";
       public         	   psatt2002    false    205            =           2606    16804    Employee Employee_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public."Employee"
    ADD CONSTRAINT "Employee_pkey" PRIMARY KEY ("ID");
 D   ALTER TABLE ONLY public."Employee" DROP CONSTRAINT "Employee_pkey";
       public            dion    false    207            ?           2606    16808    Outsource Outsource_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public."Outsource"
    ADD CONSTRAINT "Outsource_pkey" PRIMARY KEY ("Oursource ID");
 F   ALTER TABLE ONLY public."Outsource" DROP CONSTRAINT "Outsource_pkey";
       public            nico    false    209            G           2606    16810 .   __EFMigrationsHistory PK___EFMigrationsHistory 
   CONSTRAINT     {   ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");
 \   ALTER TABLE ONLY public."__EFMigrationsHistory" DROP CONSTRAINT "PK___EFMigrationsHistory";
       public            postgres    false    214            A           2606    16812    Project Project_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public."Project"
    ADD CONSTRAINT "Project_pkey" PRIMARY KEY ("ID");
 B   ALTER TABLE ONLY public."Project" DROP CONSTRAINT "Project_pkey";
       public            dion    false    210            C           2606    16814    Task Task_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_pkey" PRIMARY KEY ("ID");
 <   ALTER TABLE ONLY public."Task" DROP CONSTRAINT "Task_pkey";
       public            dhillebrand    false    211            E           2606    16816    Timesheet Timesheet Entry_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public."Timesheet"
    ADD CONSTRAINT "Timesheet Entry_pkey" PRIMARY KEY ("EntryID");
 L   ALTER TABLE ONLY public."Timesheet" DROP CONSTRAINT "Timesheet Entry_pkey";
       public            nico    false    213            Z           2620    16970    Timesheet Update_Project_Cost    TRIGGER     �   CREATE TRIGGER "Update_Project_Cost" AFTER INSERT OR DELETE OR UPDATE ON public."Timesheet" FOR EACH ROW EXECUTE FUNCTION public."Update_Project_Cost"();
 :   DROP TRIGGER "Update_Project_Cost" ON public."Timesheet";
       public          nico    false    220    213            Y           2620    16957    Task Update_Staus_of_checkpoint    TRIGGER     �   CREATE TRIGGER "Update_Staus_of_checkpoint" AFTER INSERT OR DELETE OR UPDATE ON public."Task" FOR EACH ROW EXECUTE FUNCTION public.update_checkpoint_status();
 <   DROP TRIGGER "Update_Staus_of_checkpoint" ON public."Task";
       public          dhillebrand    false    219    211            X           2620    16980    Project check_project_budget    TRIGGER     �   CREATE TRIGGER check_project_budget BEFORE INSERT OR UPDATE OF "Cost", "Budget" ON public."Project" FOR EACH ROW EXECUTE FUNCTION public.update_project_cost();
 7   DROP TRIGGER check_project_budget ON public."Project";
       public          dion    false    210    221    210    210            W           2620    16901    Employee tr_employeechanges    TRIGGER     �   CREATE TRIGGER tr_employeechanges AFTER INSERT OR DELETE OR UPDATE ON public."Employee" FOR EACH ROW EXECUTE FUNCTION public.employeechanges();
 6   DROP TRIGGER tr_employeechanges ON public."Employee";
       public          dion    false    207    218            I           2606    16817 $   Checkpoint Checkpoint_ProjectID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Checkpoint"
    ADD CONSTRAINT "Checkpoint_ProjectID_fkey" FOREIGN KEY ("ProjectID") REFERENCES public."Project"("ID");
 R   ALTER TABLE ONLY public."Checkpoint" DROP CONSTRAINT "Checkpoint_ProjectID_fkey";
       public          dion    false    2881    203    210            P           2606    16822    Project ClientID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Project"
    ADD CONSTRAINT "ClientID_fkey" FOREIGN KEY ("ClientID") REFERENCES public."Client"("ID") NOT VALID;
 C   ALTER TABLE ONLY public."Project" DROP CONSTRAINT "ClientID_fkey";
       public          dion    false    210    204    2873            J           2606    16827    Client Client_ProjectID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Client"
    ADD CONSTRAINT "Client_ProjectID_fkey" FOREIGN KEY ("ProjectID") REFERENCES public."Project"("ID");
 J   ALTER TABLE ONLY public."Client" DROP CONSTRAINT "Client_ProjectID_fkey";
       public          mz    false    204    210    2881            Q           2606    16832    Project DepartmentID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Project"
    ADD CONSTRAINT "DepartmentID_fkey" FOREIGN KEY ("DepartmentID") REFERENCES public."Department"("ID") NOT VALID;
 G   ALTER TABLE ONLY public."Project" DROP CONSTRAINT "DepartmentID_fkey";
       public          dion    false    2875    210    205            H           2606    16837    Authentication EmployeeID    FK CONSTRAINT     �   ALTER TABLE ONLY public."Authentication"
    ADD CONSTRAINT "EmployeeID" FOREIGN KEY ("EmployeeID") REFERENCES public."Employee"("ID") NOT VALID;
 G   ALTER TABLE ONLY public."Authentication" DROP CONSTRAINT "EmployeeID";
       public       	   psatt2002    false    202    2877    207            M           2606    16842 !   Employee Employee_department_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Employee"
    ADD CONSTRAINT "Employee_department_fkey" FOREIGN KEY ("DepartmentID") REFERENCES public."Department"("ID");
 O   ALTER TABLE ONLY public."Employee" DROP CONSTRAINT "Employee_department_fkey";
       public          dion    false    2875    207    205            N           2606    16847 "   Employee Employee_supervision_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Employee"
    ADD CONSTRAINT "Employee_supervision_fkey" FOREIGN KEY ("SupervisorID") REFERENCES public."Employee"("ID");
 P   ALTER TABLE ONLY public."Employee" DROP CONSTRAINT "Employee_supervision_fkey";
       public          dion    false    207    207    2877            R           2606    16852    Project ManagerID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Project"
    ADD CONSTRAINT "ManagerID_fkey" FOREIGN KEY ("SupervisorID") REFERENCES public."Employee"("ID") NOT VALID;
 D   ALTER TABLE ONLY public."Project" DROP CONSTRAINT "ManagerID_fkey";
       public          dion    false    2877    210    207            O           2606    16857    Outsource Outsource_TaskID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Outsource"
    ADD CONSTRAINT "Outsource_TaskID_fkey" FOREIGN KEY ("TaskID") REFERENCES public."Task"("ID");
 M   ALTER TABLE ONLY public."Outsource" DROP CONSTRAINT "Outsource_TaskID_fkey";
       public          nico    false    209    211    2883            K           2606    16867    Client ProjectID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Client"
    ADD CONSTRAINT "ProjectID_fkey" FOREIGN KEY ("ID") REFERENCES public."Project"("ID") NOT VALID;
 C   ALTER TABLE ONLY public."Client" DROP CONSTRAINT "ProjectID_fkey";
       public          mz    false    204    2881    210                       0    0 '   CONSTRAINT "ProjectID_fkey" ON "Client"    COMMENT     S   COMMENT ON CONSTRAINT "ProjectID_fkey" ON public."Client" IS 'PROJECT FOR CLIENT';
          public          mz    false    2891            L           2606    16872    Department Supervisor    FK CONSTRAINT     �   ALTER TABLE ONLY public."Department"
    ADD CONSTRAINT "Supervisor" FOREIGN KEY ("SupervisorID") REFERENCES public."Employee"("ID") NOT VALID;
 C   ALTER TABLE ONLY public."Department" DROP CONSTRAINT "Supervisor";
       public       	   psatt2002    false    2877    205    207            S           2606    16877    Task Task_Assignee_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_Assignee_fkey" FOREIGN KEY ("Assignee") REFERENCES public."Employee"("ID");
 E   ALTER TABLE ONLY public."Task" DROP CONSTRAINT "Task_Assignee_fkey";
       public          dhillebrand    false    211    207    2877            T           2606    16882    Task Task_CheckpointID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_CheckpointID_fkey" FOREIGN KEY ("CheckpointID") REFERENCES public."Checkpoint"("ID");
 I   ALTER TABLE ONLY public."Task" DROP CONSTRAINT "Task_CheckpointID_fkey";
       public          dhillebrand    false    2871    211    203            U           2606    16887 )   Timesheet Timesheet Entry_Project ID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Timesheet"
    ADD CONSTRAINT "Timesheet Entry_Project ID_fkey" FOREIGN KEY ("ProjectID") REFERENCES public."Project"("ID");
 W   ALTER TABLE ONLY public."Timesheet" DROP CONSTRAINT "Timesheet Entry_Project ID_fkey";
       public          nico    false    213    210    2881            V           2606    16892 (   Timesheet Timesheet Entry_Worker ID_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."Timesheet"
    ADD CONSTRAINT "Timesheet Entry_Worker ID_fkey" FOREIGN KEY ("WorkerID") REFERENCES public."Employee"("ID");
 V   ALTER TABLE ONLY public."Timesheet" DROP CONSTRAINT "Timesheet Entry_Worker ID_fkey";
       public          nico    false    2877    213    207            �   �   x����
�0Fw�"dQA
U;u� �V��~5�b"&R��5�V���p���IZ�y�����~�9kv8uK�fh&F�t{g��C�p.�|����'��	�����@��c���p�Ä~��dC9i�@c��Cß���7Π��������t��|�?t����/��InY/���`      �     x�͖]o�0���+����B���T����BJ�4�.]p�6��_?����Ғe|������ ��QA��@ռ�4�_�$}�JZp��1cAXZӊӲ�f�q����������'Iy�����P�0�^��(
A���8Y�a��z]�:�;s�c;�9�	ؕ5��rw�O��,],�rmaM������	'���(Њ���>�S��=�첾��mO�ROļ�u�:ը-fP��R�q�N��U-_˚�w���]���k�9�WZ��~8~E��$GD~S���u!�9a�O�g
{�9vBXω���wT�.������n�L<���<�o�(��L�eXښ�m�Ui�\������b;p���t��\*��O��硍{F�4��EGw*t��;˴e�������]�3�@ψ8���X.Rzf�;%�J����T�{��>�ܫ��r֣|8kS�ol�v�er�,۵�y� �~E��!"�Z����g,4w-4��RF���� �`��}��5�Dy��J��0F��d�q      �   
   x���          �   �  x�͗Mo�0���+F\H$T�i�C	7�"DZ�D=EfYZ0�6�������s��e3�^�祒�
�z�y���ye8k�G4>��(Ϣ�R�xx/c��eڽ�q�߈���2�}��d�[�c{	Or�ͳ���]U��n�Gy|*�X�	�_z���|����ǢH��/?���(��^۟�{��hm�� op�}���:�ډ w���0�����*PV!�����q�";R2��v�M[i�� �cZnx�~<i�/)SBKŚ!���)?2q�r~����B;����H�!_Q�����)+g�Ʒ�؛�y�}?~e�ԒM���Z�E��6{v�Ѩ��5(:ݠc(>�|ڴ��Ϻ��_%UE;��L��Ii�B�#�:�s��9�1-=�Ut8e(]J���y��E�н)yB�a<74VpT�3굱��q�n�8�ޡ��tXO5C��ӕ���꜃����߷���_Fv1      �   �  x�ݔ�n�0��y
+Z)A�&�T�P�tK��*���h`H��#�M�����4[�D��1�f~�!���jM�x�$�6-E��ծl> ��b���;\�ƹ�s	Jw-t	�y�Ά��RWPk��;�{�i�wB*�/����mj��*��i|Mȵy�C	�K�|��VQ�?I�+Y�����yn�	��tD��ڊ��4Țv�e�m�.�3"��bq�NF�z�Ƅ�]55
��.V�:�&/x���f�	�)�Ai�����9�y�=��s��	e�	әs~��AT���U@en�T�h�2�������&a1,�E���c�?Cf�V8�Ao{nv����ߙ��췡�����GX���
�)��).��I��dW#a�^k���
i������3z�����k�J��rf�^Ϯp��aeg��7MT�|�m�82�#�\��I�읨y�Y��:��Ҿ0'ee��X�>Ņ|:���	���/�D      �   
   x���          �   �  x��]o�0���+���J��V��hCj�.���;NRo#�t�~�lLHKH����x��'������e�2�ї�=g� �=t�ƽ>�M���˹�#&dqN(����-��P��!#\n��0π�R�xiK"sa����,-'�Y8��qyCb56{^��@���|���w>���z��}��c�ν>���B�����}���S]۶�GX�x�n҈m2��2�P�6h�8���l=�m<؎��-o�`e�H"��$����Y�y�b͈�8��SE����2�Xq��Ć{b���sTxZ#��N���9�#WE�&7��$����qr:lU�jlS���VT����۝֎@�V��Ȓ@wt�����ۡstMX��(3T�R���"�u$K��"�3'���!}4�G/��u��K��C�0��u\�we�l���r9f�`w����V�@�kS@P�B6�I�v��p�c�A�G���j�)��
����a1�D�(�&��"4]єʭU3Zs��@ݦ���kE*���@���� �5):����r�/)�13'Z�ŭy�1����.77q��R$U��j���_h���م�ֱF9��=�^�]��Z���Lʶ���� >����꺣J�7����Y�w�6Stu:՛D���TU�-�hR��Y���Ĕj��m�tO���$��-�p�yv��c�      �     x�Օ�n�0��<ň�U���-�*Њ���h�X$v6v���w�DMX����9�{Ɩ��?�h��D���>��p��i7�ذ��0\Vh�^SLN��DK���G�.V�lX��4�v[Q'�(�P�$��[x���hm�A�#ޅk�x^}�g7���o1����8�=R�1�1�Bi�����6p&�#�]h�4��c"����W����4�>����l�Z^�O�V�9���5�2I��,h�#a�3�&�O��������/(�nk���&`��dL뾔��F!�e�4
�F+V�$��u�/m0��x팿��Q�䐪��z�z�/H�{�.\��6.�)�R��C�.رd99^��P(m���gfOx�v�{;m��K���M�h�0MDEfz�A]vn���Q��EǒJ~���b�AH�v��?��Q�E;Y5�L�Yk�5ɳ*3���.鳏l�����	��k�&�/�ۂ��/>2-�����.�3+���إ5����J      �   (  x���OO�0 �;��[�-��`�'�6Qf g<n��)�)�෷��v�<.�5����SYTyY�,�-���t\���K��J�fa�7*$�w��_:��w̿�����t�����z��*��9lwyY�LwP�Vu��ۇ��+�E�r��񂉈@L`C`E���m��j~Ht̄ cI1C��-��S0z@��P�I(�I(W%����3A�d�F�ȝ�5�b�N�=�کD;/����Tbk�LW�)n&�Lẝ�:�N�N�}����_�@)bg]Ř��e�>�ow�D���Y��x      �   �   x���v
Q���W((M��L�S��wu��L/J,���+��,.�/�TR�P�z�(�((委&���Ŕ4�}B]�4ԍ����M��L�=�2K2s@
�KRS܋�J\��Ʃ�(���虨kZsqq ^.�     